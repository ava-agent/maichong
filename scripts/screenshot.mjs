import puppeteer from 'puppeteer-core';
import { spawn } from 'child_process';
import { rename, mkdir } from 'fs/promises';
import { resolve } from 'path';

const CHROME = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
const OUTPUT = resolve('docs/screenshots');
const ENV_FILE = resolve('.env');
const ENV_BAK = resolve('.env.bak');

function sleep(ms) { return new Promise(r => setTimeout(r, ms)); }

async function main() {
  await mkdir(OUTPUT, { recursive: true });

  // Step 1: Temporarily hide .env so Vite starts in demo mode
  console.log('Hiding .env to enable demo mode...');
  try { await rename(ENV_FILE, ENV_BAK); } catch {}

  // Step 2: Start local dev server (demo mode, no Supabase)
  console.log('Starting local dev server...');
  const server = spawn('npx', ['vite', '--port', '4173', '--host'], {
    cwd: resolve('.'),
    stdio: ['pipe', 'pipe', 'pipe'],
  });

  await new Promise((res) => {
    server.stdout.on('data', (data) => {
      const str = data.toString();
      if (str.includes('Local:') || str.includes('4173')) res();
    });
    setTimeout(res, 6000);
  });
  await sleep(1000);

  const LOCAL = 'http://localhost:4173';
  console.log(`Dev server at ${LOCAL}`);

  const browser = await puppeteer.launch({
    executablePath: CHROME,
    headless: 'new',
    args: ['--no-sandbox', '--disable-gpu'],
  });
  const page = await browser.newPage();
  await page.setViewport({ width: 390, height: 844, deviceScaleFactor: 2 });

  try {
    // =====================
    // Screenshot 1: Auth page
    // =====================
    console.log('\n[1/6] Auth page...');
    await page.goto(`${LOCAL}/#/auth`, { waitUntil: 'networkidle2', timeout: 15000 });
    await sleep(1500);
    await page.screenshot({ path: `${OUTPUT}/01-auth.png` });
    console.log('  saved');

    // =====================
    // Enter demo mode
    // =====================
    console.log('\n  Entering demo mode...');
    await page.click('.btn-primary');
    await sleep(2000);

    // Inject demo timelines into localStorage and trigger re-render
    await page.evaluate(() => {
      const timelines = [
        {
          id: 'tl-001', title: '周末约会计划',
          owner_id: 'demo', invite_code: 'abc123',
          created_at: new Date().toISOString(), updated_at: new Date().toISOString(),
        },
        {
          id: 'tl-002', title: '家庭聚餐',
          owner_id: 'demo', invite_code: 'def456',
          created_at: new Date(Date.now() - 86400000).toISOString(), updated_at: new Date().toISOString(),
        },
        {
          id: 'tl-003', title: '健身打卡',
          owner_id: 'demo', invite_code: 'ghi789',
          created_at: new Date(Date.now() - 172800000).toISOString(), updated_at: new Date().toISOString(),
        }
      ];
      localStorage.setItem('maichong_timelines', JSON.stringify(timelines));
      window.dispatchEvent(new HashChangeEvent('hashchange'));
    });
    await sleep(1000);

    // =====================
    // Screenshot 2: Home page with timelines
    // =====================
    console.log('[2/6] Home page...');
    await page.screenshot({ path: `${OUTPUT}/02-home.png` });
    console.log('  saved');

    // =====================
    // Screenshot 3: Timeline detail page
    // =====================
    console.log('\n[3/6] Timeline page...');
    // Inject events
    await page.evaluate(() => {
      const today = new Date().toISOString().split('T')[0];
      const tomorrow = new Date(Date.now() + 86400000).toISOString().split('T')[0];
      const events = [
        { id: 'ev-001', timeline_id: 'tl-001', title: '咖啡馆见面', description: '在星巴克聊聊近况', event_date: today, start_time: '10:00', end_time: '11:30', is_all_day: false, status: 'confirmed', created_by: 'demo', created_at: new Date().toISOString() },
        { id: 'ev-002', timeline_id: 'tl-001', title: '逛公园', description: '下午去人民公园散步', event_date: today, start_time: '14:00', end_time: '16:00', is_all_day: false, status: 'confirmed', created_by: 'demo', created_at: new Date().toISOString() },
        { id: 'ev-003', timeline_id: 'tl-001', title: '晚餐 · 日料餐厅', description: '预订了松子日料，靠窗位', event_date: today, start_time: '18:30', end_time: '20:00', is_all_day: false, status: 'proposal', created_by: 'demo', created_at: new Date().toISOString() },
        { id: 'ev-004', timeline_id: 'tl-001', title: '看电影', description: '新上映的科幻片', event_date: tomorrow, start_time: '15:00', end_time: '17:30', is_all_day: false, status: 'tentative', created_by: 'demo', created_at: new Date().toISOString() },
      ];
      const allEvents = JSON.parse(localStorage.getItem('maichong_events') || '{}');
      allEvents['tl-001'] = events;
      localStorage.setItem('maichong_events', JSON.stringify(allEvents));
    });

    // Click the first timeline card
    const card = await page.$('.timeline-card');
    if (card) {
      await card.click();
      await sleep(2000);
    } else {
      await page.evaluate(() => { window.location.hash = '/timeline/tl-001'; });
      await sleep(1500);
    }

    await page.screenshot({ path: `${OUTPUT}/03-timeline.png` });
    console.log('  saved');

    // =====================
    // Screenshot 4: Chat page
    // =====================
    console.log('\n[4/6] Chat page...');
    // Navigate to chat via tab bar (shows welcome with capability cards)
    const chatTab = await page.$('.tab-item[data-tab="chat"]');
    if (chatTab) {
      await chatTab.click();
    } else {
      await page.evaluate(() => { window.location.hash = '/timeline/tl-001/chat'; });
    }
    await sleep(2000);

    await page.screenshot({ path: `${OUTPUT}/04-chat.png` });
    console.log('  saved');

    // =====================
    // Screenshot 5: Profile page
    // =====================
    console.log('\n[5/6] Profile page...');
    const profileTab = await page.$('.tab-item[data-tab="profile"]');
    if (profileTab) {
      await profileTab.click();
    } else {
      await page.evaluate(() => { window.location.hash = '/profile'; });
    }
    await sleep(1500);

    await page.screenshot({ path: `${OUTPUT}/05-profile.png` });
    console.log('  saved');

    // =====================
    // Screenshot 6: Event creation modal
    // =====================
    console.log('\n[6/6] Event creation modal...');
    // Go back to timeline
    const timelineTab = await page.$('.tab-item[data-tab="timeline"]');
    if (timelineTab) {
      await timelineTab.click();
    } else {
      await page.evaluate(() => { window.location.hash = '/timeline/tl-001'; });
    }
    await sleep(1500);

    // Click FAB to open event creation form
    const fab = await page.$('.fab');
    if (fab) {
      await fab.click();
      await sleep(800);
    }

    await page.screenshot({ path: `${OUTPUT}/06-event-form.png` });
    console.log('  saved');

  } finally {
    await browser.close();
    server.kill();

    console.log('\nRestoring .env...');
    try { await rename(ENV_BAK, ENV_FILE); } catch {}
  }

  console.log('\nAll 6 screenshots saved to docs/screenshots/');
}

main().catch(async (e) => {
  console.error(e);
  try { await rename(ENV_BAK, ENV_FILE); } catch {}
  process.exit(1);
});
