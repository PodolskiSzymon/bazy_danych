// Robi obrazy do docs/img/ z web/index.html i narzedzia/diagramy.html.
// Użycie: python narzedzia/build_web.py && python narzedzia/gen_diagramy.py && node narzedzia/render_img.js
// (wymaga pakietu playwright z przeglądarką Chromium)
const path = require('path');
const { chromium } = require('playwright');

const root = path.join(__dirname, '..');
const img = name => path.join(root, 'docs', 'img', name);

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: 1200, height: 900 } });
  const url = 'file://' + path.join(root, 'web', 'index.html');
  await page.goto(url);
  await page.evaluate(() => document.fonts.ready);
  await page.screenshot({ path: img('mapa-calosc.png'), fullPage: true });
  for (let n = 1; n <= 6; n++) {
    await page.goto(url + '#warstwa-' + n);
    await page.waitForTimeout(300);
    // mini-mapa całej struktury zwinięta, jak na pierwszych obrazach
    await page.evaluate(() => document.querySelectorAll('details[open]').forEach(d => d.removeAttribute('open')));
    await page.screenshot({ path: img(`warstwa-${n}.png`), fullPage: true });
  }
  await page.setViewportSize({ width: 1400, height: 900 });
  await page.goto('file://' + path.join(__dirname, 'diagramy.html'));
  await page.evaluate(() => document.fonts.ready);
  await (await page.$('#dfd')).screenshot({ path: img('dfd-poziom-1.png') });
  await (await page.$('#droga')).screenshot({ path: img('droga-zgloszenia.png') });
  await browser.close();
})();
