"""Turn the handoff markdown into a Word document and a plain text file."""
import re
from pathlib import Path

from docx import Document
from docx.shared import Pt

SRC = Path(r'E:\DSH-Fuxi\HANDOFF-2026-11-01.md')
OUT_DIR = Path(r'C:\Users\USER\Desktop\小米13')
OUT_DIR.mkdir(parents=True, exist_ok=True)

text = SRC.read_text(encoding='utf-8')

# plain text: drop the markdown ornaments but keep the content
plain = re.sub(r'^#{1,6}\s*', '', text, flags=re.M)
plain = re.sub(r'\*\*([^*]+)\*\*', r'\1', plain)
plain = plain.replace('|---|', '|')
(OUT_DIR / 'fuxi-进度交接.txt').write_text(plain, encoding='utf-8')
print('txt:', (OUT_DIR / 'fuxi-进度交接.txt').stat().st_size, '字节')

doc = Document()
style = doc.styles['Normal']
style.font.name = 'Microsoft YaHei'
style.font.size = Pt(10)

for line in text.splitlines():
    stripped = line.strip()
    if not stripped:
        continue
    if stripped.startswith('#'):
        level = len(stripped) - len(stripped.lstrip('#'))
        doc.add_heading(stripped.lstrip('#').strip(), level=min(level, 4))
    elif stripped.startswith('|'):
        # tables are kept as monospaced lines: the markdown pipes read fine there
        para = doc.add_paragraph(stripped)
        para.runs[0].font.name = 'Consolas'
        para.runs[0].font.size = Pt(8)
    elif stripped.startswith('```'):
        continue
    elif stripped.startswith('- ') or stripped.startswith('* '):
        doc.add_paragraph(stripped[2:], style='List Bullet')
    elif re.match(r'^\d+\.\s', stripped):
        doc.add_paragraph(re.sub(r'^\d+\.\s', '', stripped), style='List Number')
    else:
        cleaned = re.sub(r'\*\*([^*]+)\*\*', r'\1', stripped)
        cleaned = re.sub(r'`([^`]+)`', r'\1', cleaned)
        doc.add_paragraph(cleaned)

out = OUT_DIR / 'fuxi-进度交接.docx'
doc.save(out)
print('docx:', out.stat().st_size, '字节')
