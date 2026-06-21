(() => {
  const dropZone = document.getElementById('drop-zone');
  const imageInput = document.getElementById('image-input');
  const preview = document.getElementById('preview');
  const previewBg = document.getElementById('preview-bg');
  const form = document.getElementById('pass-form');
  const generateBtn = document.getElementById('generate-btn');
  const btnLabel = document.getElementById('btn-label');
  const btnSpinner = document.getElementById('btn-spinner');
  const errorMsg = document.getElementById('error-msg');
  const certWarning = document.getElementById('cert-warning');
  const certWarningDetail = document.getElementById('cert-warning-detail');
  const passPreview = document.getElementById('pass-preview');

  // Check cert status on load
  fetch('/certs-status')
    .then(r => r.json())
    .then(status => {
      const missing = Object.entries(status).filter(([, ok]) => !ok).map(([f]) => f);
      if (missing.length) {
        certWarningDetail.textContent = missing.join(', ') + '. ';
        certWarning.classList.remove('hidden');
      }
    })
    .catch(() => {});

  // Drop zone
  dropZone.addEventListener('click', (e) => {
    if (e.target !== imageInput) imageInput.click();
  });

  dropZone.addEventListener('dragover', (e) => {
    e.preventDefault();
    dropZone.classList.add('dragover');
  });

  dropZone.addEventListener('dragleave', () => dropZone.classList.remove('dragover'));

  dropZone.addEventListener('drop', (e) => {
    e.preventDefault();
    dropZone.classList.remove('dragover');
    const file = e.dataTransfer.files[0];
    if (file && file.type.startsWith('image/')) loadImage(file);
  });

  imageInput.addEventListener('change', () => {
    if (imageInput.files[0]) loadImage(imageInput.files[0]);
  });

  function loadImage(file) {
    const url = URL.createObjectURL(file);
    preview.src = url;
    preview.classList.remove('hidden');
    dropZone.querySelector('.drop-zone-inner').classList.add('hidden');
    previewBg.style.backgroundImage = `url('${url}')`;
    // Transfer file to the form's input
    const dt = new DataTransfer();
    dt.items.add(file);
    imageInput.files = dt.files;
  }

  // Color pickers — sync hex display and pass preview background
  ['backgroundColor', 'foregroundColor', 'labelColor'].forEach(id => {
    const input = document.getElementById(id);
    const label = document.getElementById(`${id}-hex`);
    input.addEventListener('input', () => {
      label.textContent = input.value;
      if (id === 'backgroundColor') {
        passPreview.style.background = input.value;
      }
    });
  });

  // Form submit
  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    errorMsg.classList.add('hidden');

    const formData = new FormData(form);

    // Convert hex colors to rgb() format expected by Apple
    ['backgroundColor', 'foregroundColor', 'labelColor'].forEach(id => {
      const hex = document.getElementById(id).value;
      formData.set(id, hexToRgb(hex));
    });

    setLoading(true);
    try {
      const res = await fetch('/generate', { method: 'POST', body: formData });
      if (!res.ok) {
        const data = await res.json().catch(() => ({ error: res.statusText }));
        throw new Error(data.error || 'Generation failed');
      }
      const blob = await res.blob();
      const desc = document.getElementById('description').value.replace(/[^a-z0-9]/gi, '_') || 'pass';
      triggerDownload(blob, `${desc}.pkpass`);
    } catch (err) {
      showError(err.message);
    } finally {
      setLoading(false);
    }
  });

  function hexToRgb(hex) {
    const r = parseInt(hex.slice(1, 3), 16);
    const g = parseInt(hex.slice(3, 5), 16);
    const b = parseInt(hex.slice(5, 7), 16);
    return `rgb(${r},${g},${b})`;
  }

  function triggerDownload(blob, filename) {
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    document.body.appendChild(a);
    a.click();
    a.remove();
    URL.revokeObjectURL(url);
  }

  function setLoading(on) {
    generateBtn.disabled = on;
    btnLabel.textContent = on ? 'Generating…' : 'Generate .pkpass';
    btnSpinner.classList.toggle('hidden', !on);
  }

  function showError(msg) {
    errorMsg.textContent = msg;
    errorMsg.classList.remove('hidden');
    errorMsg.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
  }
})();
