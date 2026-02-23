import puppeteer from 'puppeteer-core';
import { spawn } from 'child_process';
import { rename } from 'fs/promises';
import { resolve } from 'path';

const CHROME = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
const OUTPUT = resolve('docs/screenshots');
const ENV_FILE = resolve('.env');
const ENV_BAK = resolve('.env.bak');

function sleep(ms) { return new Promise(r => setTimeout(r, ms)); }

async function main() {
  // Step 1: Temporarily hide .env so Vite starts in demo mode
  console.log('Hiding .env to enable demo mode...');
  try { await rename(ENV_FILE, ENV_BAK); } catch {}

  // Step 2: Start local dev server (demo mode, no Supabase)
  console.log('Starting local dev server...');
  const server = spawn('npx', ['vite', '--port', '4173', '--host'], {
    cwd: resolve('.'),
    stdio: ['pipe', 'pipe', 'pipe'],
  });

  await new Promise((resolve) => {
    server.stdout.on('data', (data) => {
      const str = data.toString();
      console.log('  vite:', str.trim());
      if (str.includes('Local:') || str.includes('4173')) resolve();
    });
    server.stderr.on('data', (data) => {
      console.log('  vite err:', data.toString().trim());
    });
    setTimeout(resolve, 6000);
  });
  await sleep(1000);

  const LOCAL = 'http://localhost:4173';
  console.log(`Dev server at ${LOCAL}`);

  // Step 3: Launch browser
  const browser = await puppeteer.launch({
    executablePath: CHROME,
    headless: 'new',
    args: ['--no-sandbox', '--disable-gpu'],
  });
  const page = await browser.newPage();
  await page.setViewport({ width: 390, height: 844, deviceScaleFactor: 2 });

  try {
    // Screenshot 1: Auth page (demo mode shows "开始体验" button)
    console.log('\n[1/4] Auth page...');
    await page.goto(`${LOCAL}/#/auth`, { waitUntil: 'networkidle2', timeout: 15000 });
    await sleep(1500);
    await page.screenshot({ path: `${OUTPUT}/01-auth.png` });
    console.log('  ✓ saved');

    // Click "开始体验" to enter demo mode
    console.log('\n[2/4] Entering demo mode and going to home...');
    await page.click('.btn-primary');
    await sleep(2000);

    // Now we should be on the home page. Inject demo timelines.
    const currentUrl = page.url();
    console.log('  Current URL:', currentUrl);

    // Inject timelines into localStorage and reload
    await page.evaluate(() => {
      const timelines = [
        {
          id: 'tl-001', title: '周末约会计划', description: '和小明的周末安排',
          owner_id: localStorage.getItem('maichong_timelines') ? JSON.parse(localStorage.getItem('maichong_timelines'))?.[0]?.owner_id : 'demo',
          invite_code: 'abc123', color: '#4C6EF5',
          created_at: new Date().toISOString(), updated_at: new Date().toISOString(),
        },
        {
          id: 'tl-002', title: '家庭聚餐', description: '春节家庭活动安排',
          owner_id: 'demo', invite_code: 'def456', color: '#00B578',
          created_at: new Date().toISOString(), updated_at: new Date().toISOString(),
        }
      ];
      localStorage.setItem('maichong_timelines', JSON.stringify(timelines));
    });

    // Reload home to show the injected timelines
    await page.goto(`${LOCAL}/#/`, { waitUntil: 'networkidle2', timeout: 15000 });
    await sleep(1500);

    // Check if we got redirected to auth (no user in store after reload)
    const urlAfterHome = page.url();
    console.log('  URL after home nav:', urlAfterHome);

    if (urlAfterHome.includes('/auth')) {
      // Click demo button again
      console.log('  Re-entering demo mode...');
      await page.click('.btn-primary');
      await sleep(1500);
    }

    // Now inject the timelines again (store is in-memory, localStorage read happens on load)
    await page.evaluate(() => {
      const timelines = [
        {
          id: 'tl-001', title: '周末约会计划', description: '和小明的周末安排',
          owner_id: 'demo', invite_code: 'abc123', color: '#4C6EF5',
          created_at: new Date().toISOString(), updated_at: new Date().toISOString(),
        },
        {
          id: 'tl-002', title: '家庭聚餐', description: '春节家庭活动安排',
          owner_id: 'demo', invite_code: 'def456', color: '#00B578',
          created_at: new Date().toISOString(), updated_at: new Date().toISOString(),
        }
      ];
      localStorage.setItem('maichong_timelines', JSON.stringify(timelines));

      // Force store update if we can reach it
      // The store is a module singleton - we can trigger a hashchange to re-render
      window.dispatchEvent(new HashChangeEvent('hashchange'));
    });
    await sleep(1000);

    await page.screenshot({ path: `${OUTPUT}/02-home.png` });
    console.log('  ✓ home saved');

    // Screenshot 3: Timeline page
    console.log('\n[3/4] Timeline page...');
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
      localStorage.setItem('maichong_events_tl-001', JSON.stringify(events));
    });

    // Click the first timeline card to navigate
    const card = await page.$('.timeline-card');
    if (card) {
      await card.click();
      await sleep(2000);
    } else {
      // Direct navigate
      await page.goto(`${LOCAL}/#/timeline/tl-001`, { waitUntil: 'networkidle2', timeout: 15000 });
      await sleep(1500);
      // May redirect to auth again
      if (page.url().includes('/auth')) {
        await page.click('.btn-primary');
        await sleep(1000);
        await page.goto(`${LOCAL}/#/timeline/tl-001`, { waitUntil: 'networkidle2', timeout: 15000 });
        await sleep(1500);
      }
    }

    await page.screenshot({ path: `${OUTPUT}/03-timeline.png` });
    console.log('  ✓ timeline saved');

    // Screenshot 4: Chat page
    console.log('\n[4/4] Chat page...');
    await page.evaluate(() => {
      const msgs = [
        { id: 'msg-1', role: 'assistant', content: '你好！我是脉冲助手，可以帮你安排日程、查看计划。有什么需要帮忙的吗？', created_at: new Date(Date.now() - 120000).toISOString() },
        { id: 'msg-2', role: 'user', content: '帮我明天下午安排看电影', created_at: new Date(Date.now() - 60000).toISOString() },
        { id: 'msg-3', role: 'assistant', content: '好的！我已经帮你在明天下午 15:00 创建了「看电影」活动，时长 2.5 小时。你可以在时间线中查看。', created_at: new Date().toISOString() },
      ];
      localStorage.setItem('maichong_chat_tl-001', JSON.stringify(msgs));
    });

    // Navigate to chat
    const chatBtns = await page.$$('.header-btn');
    let navigatedToChat = false;
    for (const btn of chatBtns) {
      const html = await btn.evaluate(el => el.innerHTML);
      if (html.includes('20 2H4') || html.includes('chat')) {
        await btn.click();
        navigatedToChat = true;
        break;
      }
    }
    if (!navigatedToChat) {
      // Direct navigate using hash
      const hash = page.url().includes('tl-001') ? 'tl-001' : 'tl-001';
      await page.evaluate((id) => {
        window.location.hash = `/timeline/${id}/chat`;
      }, hash);
    }
    await sleep(2000);

    await page.screenshot({ path: `${OUTPUT}/04-chat.png` });
    console.log('  ✓ chat saved');

  } finally {
    await browser.close();
    server.kill();

    // Restore .env
    console.log('\nRestoring .env...');
    try { await rename(ENV_BAK, ENV_FILE); } catch {}
  }

  console.log('\nAll screenshots saved to docs/screenshots/');
}

main().catch(async (e) => {
  console.error(e);
  // Restore .env on error
  try { await rename(ENV_BAK, ENV_FILE); } catch {}
  process.exit(1);
});
