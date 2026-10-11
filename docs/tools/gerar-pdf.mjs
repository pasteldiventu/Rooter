// Uso: cd docs/tools && npm install && node gerar-pdf.mjs
// Opcional: BROWSER_PATH=<caminho do Chrome/Edge> para usar outro navegador.
import { existsSync, readFileSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { Marked } from 'marked';
import puppeteer from 'puppeteer-core';

const here = dirname(fileURLToPath(import.meta.url));
const docsDir = resolve(here, '..');
const mdPath = join(docsDir, 'DOCUMENTACAO_ROOTER.md');
const htmlPath = join(tmpdir(), 'DOCUMENTACAO_ROOTER.html');
const pdfPath = join(docsDir, 'DOCUMENTACAO_ROOTER.pdf');

const browserCandidates = [
  process.env.BROWSER_PATH,
  'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe',
  'C:\\Program Files\\Microsoft\\Edge\\Application\\msedge.exe',
  'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
  '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
  '/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge',
  '/usr/bin/google-chrome',
  '/usr/bin/chromium',
  '/usr/bin/microsoft-edge',
].filter(Boolean);

const browserPath = browserCandidates.find((p) => existsSync(p));
if (!browserPath) {
  console.error('Nenhum Chrome/Edge encontrado. Defina BROWSER_PATH.');
  process.exit(1);
}

// Mesmo algoritmo de âncoras do GitHub, para os links do sumário funcionarem.
const slugify = (text) =>
  text
    .toLowerCase()
    .replace(/<[^>]+>/g, '')
    .replace(/[^\p{L}\p{N}\s_-]/gu, '')
    .trim()
    .replace(/\s/g, '-');

const marked = new Marked({ gfm: true });
marked.use({
  renderer: {
    heading({ tokens, depth, text }) {
      const html = this.parser.parseInline(tokens);
      return `<h${depth} id="${slugify(text)}">${html}</h${depth}>\n`;
    },
    listitem(item) {
      const body = this.parser.parse(item.tokens, !!item.loose);
      if (item.task) {
        const box = item.checked ? '☑' : '☐';
        return `<li class="task"><span class="box">${box}</span>${body.replace(/<input[^>]*>\s*/, '')}</li>\n`;
      }
      return `<li>${body}</li>\n`;
    },
  },
});

const markdown = readFileSync(mdPath, 'utf8');
const body = marked.parse(markdown);
const today = new Date().toLocaleDateString('pt-BR');

const css = `
  @page { size: A4; margin: 18mm 16mm 20mm 16mm; }
  :root { --blue: #17458F; --gold: #F7A81B; --ink: #1d2433; --muted: #5b6475; --line: #d9dee8; }
  * { box-sizing: border-box; }
  html { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
  body { font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif; color: var(--ink);
         font-size: 10.5pt; line-height: 1.5; margin: 0; }
  .cover { height: 255mm; display: flex; flex-direction: column; justify-content: center;
           page-break-after: always; border-left: 10px solid var(--gold); padding-left: 18mm; }
  .cover .tag { color: var(--gold); font-weight: 700; letter-spacing: .2em; text-transform: uppercase; font-size: 11pt; }
  .cover h1 { font-size: 40pt; color: var(--blue); margin: 6mm 0 2mm; border: 0; padding: 0; }
  .cover .sub { font-size: 15pt; color: var(--muted); margin-bottom: 14mm; }
  .cover .wheel { width: 34mm; height: 34mm; border-radius: 50%; border: 6px solid var(--gold);
                  display: flex; align-items: center; justify-content: center; color: var(--blue);
                  font-weight: 800; font-size: 20pt; margin-bottom: 10mm; }
  .cover dl { display: grid; grid-template-columns: 45mm auto; gap: 2mm 6mm; font-size: 11pt; margin: 0; }
  .cover dt { color: var(--muted); }
  .cover dd { margin: 0; font-weight: 600; }
  h1, h2, h3, h4 { color: var(--blue); line-height: 1.25; page-break-after: avoid; break-after: avoid; }
  h1 { font-size: 22pt; margin: 0 0 4mm; }
  h2 { font-size: 16pt; border-bottom: 3px solid var(--gold); padding-bottom: 2mm; margin-top: 0;
       page-break-before: always; break-before: page; }
  h3 { font-size: 12.5pt; margin-top: 7mm; }
  h4 { font-size: 11pt; margin-top: 5mm; color: var(--ink); }
  body > h1:first-of-type, body > h1:first-of-type + p, body > h1:first-of-type + p + table,
  body > h1:first-of-type + p + table + hr { display: none; }
  #sumário { page-break-before: avoid; break-before: auto; }
  a { color: var(--blue); text-decoration: none; }
  p, li { orphans: 3; widows: 3; }
  hr { border: 0; border-top: 1px solid var(--line); margin: 6mm 0; }
  hr + h2 { margin-top: 0; }
  table { width: 100%; border-collapse: collapse; margin: 3mm 0 5mm; font-size: 9.3pt; page-break-inside: auto; }
  tr { page-break-inside: avoid; break-inside: avoid; }
  thead { display: table-header-group; }
  th { background: var(--blue); color: #fff; text-align: left; padding: 2mm 2.5mm; font-weight: 600; }
  td { padding: 1.6mm 2.5mm; border-bottom: 1px solid var(--line); vertical-align: top; }
  tbody tr:nth-child(even) td { background: #f5f7fb; }
  code { font-family: 'Cascadia Mono', Consolas, 'Courier New', monospace; font-size: 8.8pt;
         background: #eef1f7; padding: .3mm 1.2mm; border-radius: 3px; }
  pre { background: #0f1b33; color: #e8edf7; padding: 4mm; border-radius: 6px; overflow: hidden;
        white-space: pre-wrap; word-break: break-word; page-break-inside: avoid; break-inside: avoid;
        font-size: 8.2pt; line-height: 1.35; }
  pre code { background: none; padding: 0; color: inherit; font-size: inherit; }
  blockquote { margin: 4mm 0; padding: 2.5mm 4mm; border-left: 4px solid var(--gold);
               background: #fff8e8; color: #4a3b12; border-radius: 0 6px 6px 0; }
  blockquote p { margin: 0; }
  ul, ol { padding-left: 6mm; }
  li.task { list-style: none; margin-left: -5mm; }
  li.task .box { color: var(--blue); margin-right: 2mm; }
  p[align="center"] { text-align: center; page-break-inside: avoid; break-inside: avoid; }
  p[align="center"] img { width: 42mm; height: auto; margin: 0 1.5mm; border-radius: 10px;
                          box-shadow: 0 2px 8px rgba(15, 27, 51, .25); }
  p[align="center"] img:only-child { width: 58mm; }
`;

const html = `<!doctype html>
<html lang="pt-BR">
<head>
<meta charset="utf-8">
<base href="${pathToFileURL(docsDir).href}/">
<title>Rooter — Documentação do Sistema</title>
<style>${css}</style>
</head>
<body>
<section class="cover">
  <div class="wheel">R</div>
  <div class="tag">Rotary Club · Mato Grosso</div>
  <h1>Rooter MT</h1>
  <div class="sub">Documentação Técnica e Funcional do Sistema</div>
  <dl>
    <dt>Versão do app</dt><dd>1.0.0 (build 1)</dd>
    <dt>Versão da API</dt><dd>0.1.0</dd>
    <dt>Stack</dt><dd>Flutter · FastAPI · Shorebird</dd>
    <dt>Escopo</dt><dd>Clubes Rotary do estado de Mato Grosso</dd>
    <dt>Gerado em</dt><dd>${today}</dd>
  </dl>
</section>
${body}
</body>
</html>`;

writeFileSync(htmlPath, html, 'utf8');

const browser = await puppeteer.launch({
  executablePath: browserPath,
  headless: true,
  args: ['--no-sandbox'],
});
try {
  const page = await browser.newPage();
  await page.goto(pathToFileURL(htmlPath).href, { waitUntil: 'load' });
  await page.pdf({
    path: pdfPath,
    format: 'A4',
    printBackground: true,
    preferCSSPageSize: true,
    displayHeaderFooter: true,
    headerTemplate: '<div></div>',
    footerTemplate: `
      <div style="width:100%;font-family:Segoe UI,Arial,sans-serif;font-size:8px;color:#5b6475;
                  padding:0 16mm;display:flex;justify-content:space-between;">
        <span>Rooter MT — Documentação do Sistema</span>
        <span>Página <span class="pageNumber"></span> de <span class="totalPages"></span></span>
      </div>`,
  });
} finally {
  await browser.close();
}

console.log(`PDF gerado: ${pdfPath}`);
