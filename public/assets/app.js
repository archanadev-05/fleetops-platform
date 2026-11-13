document.addEventListener('click', (event) => {
  const open = event.target.closest('[data-open]');
  if (open) {
    const dialog = document.getElementById(open.dataset.open);
    if (dialog?.id === 'vehicle-modal') {
      const form = dialog.querySelector('form');
      const data = open.dataset;
      form.elements.id.value = data.vehicleId || '';
      form.elements.plate_number.value = data.plate || '';
      form.elements.model.value = data.model || '';
      form.elements.year.value = data.year || '';
      form.elements.fuel_type.value = data.fuel || 'DIESEL';
      form.elements.status.value = data.status || 'ACTIVE';
      form.elements.current_odometer.value = data.odometer || 0;
      form.elements.insurance_expiry.value = data.insurance || '';
      form.elements.revenue_lic_expiry.value = data.license || '';
      dialog.querySelector('h2').textContent = data.vehicleId ? 'Edit vehicle' : 'Add a vehicle';
    }
    dialog?.showModal();
  }
  const close = event.target.closest('[data-close]');
  if (close) close.closest('dialog')?.close();
  const confirm = event.target.closest('[data-confirm]');
  if (confirm && !window.confirm(confirm.dataset.confirm)) event.preventDefault();
});
document.querySelectorAll('[data-filter]').forEach((input) => {
  input.addEventListener('input', () => {
    const table = document.querySelector(`[data-table="${input.dataset.filter}"]`);
    // Current tables expose their rows directly; search all rows in the nearest panel.
    const rows = input.closest('.content')?.querySelectorAll('[data-search-row]') || table?.querySelectorAll('[data-search-row]');
    rows?.forEach((row) => { row.hidden = !row.textContent.toLowerCase().includes(input.value.toLowerCase()); });
  });
});
document.querySelectorAll('dialog').forEach((dialog) => dialog.addEventListener('click', (event) => {
  if (event.target === dialog) dialog.close();
}));
