# Common Gotchas

Platform-specific issues discovered during Ralph Loop development.

## TypeScript / Vite

### verbatimModuleSyntax Import Error

**Error:** `The requested module does not provide an export named 'X'`

**Context:** Vite React TypeScript template has `verbatimModuleSyntax: true` in tsconfig

**Cause:** Type-only imports must use `import type` syntax

**Solution:**
```typescript
// Wrong
import { ElementData } from './types';

// Correct
import type { ElementData } from './types';
```

---

## react-pdf

### ArrayBuffer Detachment

**Error:**
- `Cannot perform Construct on a detached ArrayBuffer`
- `DataCloneError: Failed to execute 'postMessage' on 'Worker'`

**Context:** Passing ArrayBuffer directly to react-pdf Document component

**Cause:** ArrayBuffer gets "detached" when transferred to PDF.js web worker

**Solution:**
```typescript
// Wrong - ArrayBuffer gets detached
const reader = new FileReader();
reader.onload = (e) => {
  setPdfData(e.target.result); // ArrayBuffer - will be detached
};

// Correct - Use blob URL for display, keep Uint8Array for export
const handleFileSelect = (file: File) => {
  // For react-pdf display
  const url = URL.createObjectURL(file);
  setPdfUrl(url);

  // For pdf-lib export (separate copy)
  const reader = new FileReader();
  reader.onload = (e) => {
    setPdfData(new Uint8Array(e.target.result as ArrayBuffer));
  };
  reader.readAsArrayBuffer(file);
};
```

---

## react-draggable

### Element Positioning

**Issue:** Draggable elements appear in wrong location

**Context:** Using `position: absolute` with react-draggable

**Cause:** react-draggable uses CSS transforms (translate) for positioning. Element needs explicit starting position.

**Solution:**
```typescript
// Wrong - no explicit starting position
<div className="draggable-element" style={{ width, height }}>

// Correct - explicit top/left
<div
  className="draggable-element"
  style={{ width, height, top: 0, left: 0 }}
>
```

Also ensure parent has `position: relative` for positioning context.

---

## PDF Coordinate Systems

### Origin Conversion

**Issue:** Elements appear in wrong position in exported PDF

**Context:** Converting screen coordinates to PDF coordinates

**Cause:** PDF uses bottom-left origin, screen uses top-left origin

**Solution:**
```typescript
// Screen to PDF coordinate conversion
const scale = pdfPageWidth / viewerDisplayWidth;
const pdfX = element.x * scale;
const pdfY = pageHeight - (element.y * scale) - (element.height * scale);
```

---

## Playwright MCP

### Dialog Handling

**Issue:** Dialog already handled error

**Context:** Using `browser_handle_dialog` after `browser_run_code` with dialog handler

**Cause:** Dialog can only be handled once

**Solution:** Choose one method:
```javascript
// Option 1: Handle in run_code
browser_run_code → async (page) => {
  page.once('dialog', dialog => dialog.accept('value'));
  await page.click('button');
}

// Option 2: Let MCP handle it
browser_click → button that triggers dialog
// Wait for MCP to report dialog
browser_handle_dialog → {accept: true, promptText: 'value'}
```

### Element Reference Stale

**Issue:** Element ref from snapshot no longer valid after page update

**Cause:** Page state changed, refs are stale

**Solution:** Take fresh snapshot before interacting:
```
browser_snapshot → get fresh refs
browser_click → use new ref
```

---

## Canvas Drawing

### Mouse Events Not Registering

**Issue:** Canvas drawing doesn't work

**Context:** Testing canvas with Playwright

**Solution:** Use explicit mouse operations:
```javascript
browser_run_code → async (page) => {
  const canvas = await page.locator('[data-testid="canvas"]');
  const box = await canvas.boundingBox();

  await page.mouse.move(box.x + 50, box.y + 50);
  await page.mouse.down();
  await page.mouse.move(box.x + 150, box.y + 100);
  await page.mouse.up();
}
```

---

## File Downloads

### Verifying Downloaded Files

**Issue:** Need to verify download completed and file contents

**Solution:**
```javascript
browser_run_code → async (page) => {
  const downloadPromise = page.waitForEvent('download');
  await page.click('[data-testid="download-btn"]');
  const download = await downloadPromise;
  return download.suggestedFilename();
}
```

Then verify file on disk:
```bash
ls -la /path/to/downloads/
head -c 100 /path/to/file  # Check file header
```
