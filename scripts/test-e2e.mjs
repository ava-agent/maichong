/**
 * End-to-end browser tests for 脉冲 (Maichong)
 * Runs against local dev server in demo mode (no .env)
 */
import puppeteer from 'puppeteer-core';
import { spawn } from 'child_process';
import { rename } from 'fs/promises';
import { resolve } from 'path';

const CHROME = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
const PORT = 4199;
const BASE = `http://localhost:${PORT}`;
const ENV_FILE = resolve('.env');
const ENV_BAK = resolve('.env.test-bak');

let passed = 0, failed = 0;
const errors = [];

function sleep(ms) { return new Promise(r => setTimeout(r, ms)); }

function assert(condition, name) {
  if (condition) {
    passed++;
    console.log(`  ✓ ${name}`);
  } else {
    failed++;
    errors.push(name);
    console.log(`  ✗ ${name}`);
  }
}

async function main() {
  // Hide .env for demo mode
  try { await rename(ENV_FILE, ENV_BAK); } catch {}

  // Start dev server
  const server = spawn('npx', ['vite', '--port', String(PORT)], {
    cwd: resolve('.'),
    stdio: ['pipe', 'pipe', 'pipe'],
  });

  await new Promise((res) => {
    server.stdout.on('data', (d) => {
      if (d.toString().includes('Local:')) res();
    });
    setTimeout(res, 6000);
  });
  await sleep(500);

  const browser = await puppeteer.launch({
    executablePath: CHROME,
    headless: 'new',
    args: ['--no-sandbox'],
  });

  const consoleErrors = [];

  try {
    const page = await browser.newPage();
    await page.setViewport({ width: 390, height: 844, deviceScaleFactor: 2 });

    // Capture console errors
    page.on('console', msg => {
      if (msg.type() === 'error') consoleErrors.push(msg.text());
    });
    page.on('pageerror', err => consoleErrors.push(err.message));

    // =====================
    // TEST 1: Auth Page Renders
    // =====================
    console.log('\n[Test Suite 1: Auth Page]');
    await page.goto(`${BASE}/#/auth`, { waitUntil: 'networkidle2' });
    await sleep(800);

    const logo = await page.$('.auth-logo');
    assert(!!logo, 'Auth page renders logo');

    const title = await page.$eval('.auth-title', el => el.textContent);
    assert(title === '脉冲', 'Auth title is "脉冲"');

    const subtitle = await page.$eval('.auth-subtitle', el => el.textContent);
    assert(subtitle === '同步每次脉冲', 'Auth subtitle is correct');

    const demoBadge = await page.$('.demo-badge');
    assert(!!demoBadge, 'Demo badge is visible');

    const demoBtn = await page.$('.btn-primary');
    assert(!!demoBtn, 'Demo "开始体验" button exists');

    // =====================
    // TEST 2: Demo Mode Login
    // =====================
    console.log('\n[Test Suite 2: Demo Login]');
    await demoBtn.click();
    await sleep(1500);

    const currentUrl = page.url();
    assert(!currentUrl.includes('/auth'), 'Navigated away from auth after demo login');
    assert(currentUrl.includes('#/'), 'Redirected to home page');

    // =====================
    // TEST 3: Home Page
    // =====================
    console.log('\n[Test Suite 3: Home Page]');

    const greetingEl = await page.$('.greeting-text');
    assert(!!greetingEl, 'Greeting text exists');

    const greeting = await page.$eval('.greeting-text', el => el.textContent);
    assert(greeting.includes('演示用户'), 'Greeting contains user name');

    const header = await page.$('.view-header');
    assert(!!header, 'Page header exists');

    const headerTitle = await page.$eval('.view-title', el => el.textContent);
    assert(headerTitle === '脉冲', 'Header title is "脉冲"');

    const fab = await page.$('.fab');
    assert(!!fab, 'FAB button exists');

    // =====================
    // TEST 4: Create Timeline
    // =====================
    console.log('\n[Test Suite 4: Create Timeline]');
    await fab.click();
    await sleep(500);

    const modal = await page.$('.modal-overlay');
    assert(!!modal, 'Create timeline modal opens');

    const modalTitle = await page.$eval('.modal-title', el => el.textContent);
    assert(modalTitle === '新建时间线', 'Modal title is correct');

    const modalInput = await page.$('.modal-content .form-input');
    assert(!!modalInput, 'Timeline name input exists');

    await modalInput.type('测试时间线');
    await sleep(200);

    const createBtn = await page.$('.modal-content .btn-primary');
    await createBtn.click();
    await sleep(1500);

    // Should navigate to timeline view
    const urlAfterCreate = page.url();
    assert(urlAfterCreate.includes('/timeline/'), 'Navigated to new timeline view');

    // =====================
    // TEST 5: Timeline View
    // =====================
    console.log('\n[Test Suite 5: Timeline View]');

    const timelineHeader = await page.$('.view-header');
    assert(!!timelineHeader, 'Timeline header exists');

    const tlTitle = await page.$eval('.view-title', el => el.textContent);
    assert(tlTitle === '测试时间线', 'Timeline title matches created name');

    const emptyState = await page.$('.empty-state');
    assert(!!emptyState, 'Empty state shown for new timeline');

    const inputBar = await page.$('.input-bar');
    assert(!!inputBar, 'Input bar exists');

    const inputField = await page.$('.input-field');
    assert(!!inputField, 'Input field exists');

    const sendBtn = await page.$('.send-btn');
    assert(!!sendBtn, 'Send button exists');

    const tlFab = await page.$('.fab');
    assert(!!tlFab, 'FAB button exists on timeline view');

    // =====================
    // TEST 6: Create Event via FAB
    // =====================
    console.log('\n[Test Suite 6: Create Event]');
    await tlFab.click();
    await sleep(500);

    const eventModal = await page.$('.modal-overlay');
    assert(!!eventModal, 'Event form modal opens');

    const eventModalTitle = await page.$eval('.modal-title', el => el.textContent);
    assert(eventModalTitle.includes('新建事件'), 'Event modal title is correct');

    // Fill in event form
    const titleInput = await page.$('.modal-content [name="title"]');
    assert(!!titleInput, 'Event title input exists');
    await titleInput.type('测试事件');

    const dateInput = await page.$('.modal-content [name="event_date"]');
    assert(!!dateInput, 'Event date input exists');

    const timeInput = await page.$('.modal-content [name="start_time"]');
    assert(!!timeInput, 'Event time input exists');

    // Submit
    const saveBtn = await page.$('.modal-content .btn-primary');
    await saveBtn.click();
    await sleep(1000);

    // Check event appears
    const pulseCard = await page.$('.pulse-card');
    assert(!!pulseCard, 'Event card appears after creation');

    const cardTitle = await page.$eval('.card-title', el => el.textContent);
    assert(cardTitle === '测试事件', 'Event card title matches');

    // =====================
    // TEST 7: Navigate to Chat
    // =====================
    console.log('\n[Test Suite 7: Chat View]');

    // Click the chat icon in header
    const headerBtns = await page.$$('.header-btn');
    // The chat button should have a chat icon (contains path with "20 2H4")
    let chatBtn = null;
    for (const btn of headerBtns) {
      const html = await btn.evaluate(el => el.innerHTML);
      // Look for the share or invite icons to find the right button set
    }
    // Navigate directly via URL
    const tlId = page.url().match(/timeline\/([^/]+)/)?.[1];
    if (tlId) {
      await page.goto(`${BASE}/#/timeline/${tlId}/chat`, { waitUntil: 'networkidle2' });
      await sleep(1000);
    }

    const chatWelcome = await page.$('.chat-welcome');
    assert(!!chatWelcome, 'Chat welcome area shown');

    const chatWelcomeTitle = await page.$eval('.chat-welcome-title', el => el.textContent);
    assert(chatWelcomeTitle.includes('脉冲助手'), 'Chat welcome title correct');

    const chips = await page.$$('.suggestion-chip');
    assert(chips.length > 0, 'Suggestion chips shown');

    const chatInput = await page.$('.input-field');
    assert(!!chatInput, 'Chat input field exists');

    const chatSend = await page.$('.send-btn');
    assert(!!chatSend, 'Chat send button exists');

    // =====================
    // TEST 8: Send Chat Message
    // =====================
    console.log('\n[Test Suite 8: Send Message]');
    await chatInput.type('你好');
    await sleep(200);
    await chatSend.click();
    await sleep(1000);

    const userMsg = await page.$('.chat-message.user');
    assert(!!userMsg, 'User message bubble appears');

    const userContent = await page.$eval('.chat-message.user .message-content p', el => el.textContent);
    assert(userContent === '你好', 'User message content correct');

    // Wait for AI response (mock mode)
    await sleep(3000);
    const aiMsg = await page.$('.chat-message.ai');
    assert(!!aiMsg, 'AI message bubble appears');

    // =====================
    // TEST 9: Navigation Back
    // =====================
    console.log('\n[Test Suite 9: Navigation]');
    const backBtn = await page.$('.header-btn');
    if (backBtn) {
      await backBtn.click();
      await sleep(1000);
    }

    const urlAfterBack = page.url();
    assert(urlAfterBack.includes('/timeline/') && !urlAfterBack.includes('/chat'), 'Navigated back to timeline from chat');

    // Navigate to home
    const homeBackBtn = await page.$('.header-btn');
    if (homeBackBtn) {
      await homeBackBtn.click();
      await sleep(1000);
    }

    const urlHome = page.url();
    assert(urlHome.endsWith('#/') || urlHome.endsWith('#'), 'Navigated back to home');

    // Check timeline card exists on home
    const timelineCard = await page.$('.timeline-card');
    assert(!!timelineCard, 'Created timeline card visible on home');

    // =====================
    // TEST 10: CSS & Layout
    // =====================
    console.log('\n[Test Suite 10: CSS & Layout]');

    const appEl = await page.$('#app');
    const appBox = await appEl.boundingBox();
    assert(appBox.width <= 430, 'App max-width constrained to 430px');
    assert(appBox.height > 0, 'App has non-zero height');

    // Check no console errors from our code
    const jsErrors = consoleErrors.filter(e =>
      !e.includes('favicon') &&
      !e.includes('ERR_CONNECTION_REFUSED') &&
      !e.includes('net::')
    );

    // =====================
    // TEST 11: Route Guard
    // =====================
    console.log('\n[Test Suite 11: Route Guard]');

    // Clear user session and reload to test guard
    await page.evaluate(() => {
      localStorage.clear();
      window.location.hash = '#/';
    });
    // Full reload to re-initialize app with empty store
    await page.reload({ waitUntil: 'networkidle2' });
    await sleep(1500);

    const guardUrl = page.url();
    assert(guardUrl.includes('/auth'), 'Route guard redirects to auth when not logged in');

    // =====================
    // CONSOLE ERRORS CHECK
    // =====================
    console.log('\n[Console Errors Check]');
    assert(jsErrors.length === 0, `No JavaScript errors (found: ${jsErrors.length})`);
    if (jsErrors.length > 0) {
      jsErrors.forEach(e => console.log(`    ERROR: ${e}`));
    }

  } finally {
    await browser.close();
    server.kill();
    try { await rename(ENV_BAK, ENV_FILE); } catch {}
  }

  // Report
  console.log('\n' + '='.repeat(50));
  console.log(`RESULTS: ${passed} passed, ${failed} failed`);
  if (errors.length > 0) {
    console.log('\nFailed tests:');
    errors.forEach(e => console.log(`  ✗ ${e}`));
  }
  console.log('='.repeat(50));

  process.exit(failed > 0 ? 1 : 0);
}

main().catch(async (e) => {
  console.error('Test runner error:', e);
  try { await rename(ENV_BAK, ENV_FILE); } catch {}
  process.exit(1);
});
