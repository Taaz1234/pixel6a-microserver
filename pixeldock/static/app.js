// PixelDock Pro - Client Controller & Real-Time Orchestrator

const state = {
  services: [],
  system: null,
  activeCategory: 'all',
  searchQuery: '',
  currentLogServiceId: null,
  isTerminalOpen: false
};

// DOM Elements
const servicesGrid = document.getElementById('servicesGrid');
const runningCount = document.getElementById('runningCount');
const stoppedCount = document.getElementById('stoppedCount');
const totalCount = document.getElementById('totalCount');
const allCount = document.getElementById('allCount');
const cpuLoadVal = document.getElementById('cpuLoadVal');
const ramUsedVal = document.getElementById('ramUsedVal');
const batteryTempVal = document.getElementById('batteryTempVal');
const searchInput = document.getElementById('searchInput');
const logsModal = document.getElementById('logsModal');
const logsConsole = document.getElementById('logsConsole');
const logModalTitle = document.getElementById('logModalTitle');
const logModalSub = document.getElementById('logModalSub');
const terminalDrawer = document.getElementById('terminalDrawer');
const terminalOutput = document.getElementById('terminalOutput');
const termCmdInput = document.getElementById('termCmdInput');
const toastContainer = document.getElementById('toastContainer');

// Initialization
document.addEventListener('DOMContentLoaded', () => {
  fetchServices();
  // Auto-polling cada 4 segundos
  setInterval(() => {
    fetchServices(false);
  }, 4000);
});

// Fetch Services & Telemetry
async function fetchServices(showToastMsg = false) {
  try {
    const res = await fetch('/api/services');
    if (!res.ok) throw new Error('Error al conectar con PixelDock API');
    const data = await res.json();
    
    state.services = data.services || [];
    state.system = data.system || null;

    updateTelemetry(data);
    renderCards();

    if (showToastMsg) {
      showToast('🔄 Estado de microservicios actualizado', 'info');
    }
  } catch (err) {
    console.error('Error fetching services:', err);
  }
}

// Update Top Bar & Stats
function updateTelemetry(data) {
  runningCount.textContent = data.running_count;
  stoppedCount.textContent = data.stopped_count;
  totalCount.textContent = data.total_services;
  allCount.textContent = data.total_services;

  if (data.system) {
    cpuLoadVal.textContent = `${data.system.cpu_pct}%`;
    ramUsedVal.textContent = `${data.system.ram_used_mb} / ${data.system.ram_total_mb} MB`;
    batteryTempVal.textContent = `${data.system.battery_temp}°C`;
  }
}

// Filter by Category
function filterCategory(cat) {
  state.activeCategory = cat;
  document.querySelectorAll('.cat-btn').forEach(btn => {
    btn.classList.toggle('active', btn.dataset.cat === cat);
  });
  renderCards();
}

// Search
function handleSearch() {
  state.searchQuery = searchInput.value.trim().toLowerCase();
  renderCards();
}

// Render Services Grid
function renderCards() {
  let filtered = state.services;

  if (state.activeCategory !== 'all') {
    filtered = filtered.filter(s => s.category === state.activeCategory);
  }

  if (state.searchQuery) {
    filtered = filtered.filter(s => 
      s.name.toLowerCase().includes(state.searchQuery) ||
      (s.port && s.port.toString().includes(state.searchQuery)) ||
      s.category.toLowerCase().includes(state.searchQuery) ||
      s.description.toLowerCase().includes(state.searchQuery)
    );
  }

  if (filtered.length === 0) {
    servicesGrid.innerHTML = `
      <div style="grid-column: 1/-1; text-align: center; padding: 3rem; color: var(--text-muted);">
        <i class="fa-solid fa-layer-group" style="font-size: 2rem; margin-bottom: 0.5rem; opacity: 0.5;"></i>
        <p>No se encontraron microservicios con ese filtro.</p>
      </div>
    `;
    return;
  }

  servicesGrid.innerHTML = filtered.map(s => `
    <div class="service-card" id="card-${s.id}">
      <div class="service-header">
        <div class="service-info-box">
          <div class="service-icon" style="color: ${s.color}; border-color: ${s.color}40;">
            <i class="fa-solid ${s.icon}"></i>
          </div>
          <div class="service-title-text">
            <h4>${s.name}</h4>
            <span class="service-category-tag">${s.category}</span>
          </div>
        </div>
        <span class="status-pill ${s.running ? 'running' : 'stopped'}">
          <i class="fa-solid fa-circle" style="font-size: 0.5rem;"></i>
          ${s.running ? 'Running' : 'Stopped'}
        </span>
      </div>

      <p class="service-desc">${s.description}</p>

      <div class="service-metrics">
        <div class="metric-item">
          <span>Puerto:</span> <strong>:${s.port || 'N/A'}</strong>
        </div>
        <div class="metric-item">
          <span>PID:</span> <strong>${s.pid || '-'}</strong>
        </div>
        <div class="metric-item">
          <span>RAM:</span> <strong>${s.running ? s.mem_mb + ' MB' : '-'}</strong>
        </div>
      </div>

      <div class="service-actions">
        <div class="ctrl-btn-group">
          ${s.running ? `
            <button class="ctrl-btn btn-stop" onclick="serviceAction('${s.id}', 'stop')" title="Detener servicio">
              <i class="fa-solid fa-stop"></i> Stop
            </button>
            <button class="ctrl-btn" onclick="serviceAction('${s.id}', 'restart')" title="Reiniciar servicio">
              <i class="fa-solid fa-arrows-rotate"></i>
            </button>
          ` : `
            <button class="ctrl-btn btn-start" onclick="serviceAction('${s.id}', 'start')" title="Iniciar servicio">
              <i class="fa-solid fa-play"></i> Start
            </button>
          `}
          <button class="ctrl-btn" onclick="openLogsModal('${s.id}', '${s.name}')" title="Ver logs en vivo">
            <i class="fa-solid fa-file-lines"></i>
          </button>
        </div>

        ${s.running && s.web_url ? `
          <a href="${s.web_url}" target="_blank" class="ctrl-btn btn-open" title="Abrir interfaz web">
            <i class="fa-solid fa-arrow-up-right-from-square"></i> Abrir
          </a>
        ` : ''}
      </div>
    </div>
  `).join('');
}

// Service Action (Start / Stop / Restart)
async function serviceAction(serviceId, action) {
  const actionText = action === 'start' ? 'Iniciando' : (action === 'stop' ? 'Deteniendo' : 'Reiniciando');
  showToast(`⏳ ${actionText} servicio...`, 'info');

  try {
    const res = await fetch('/api/service/action', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ id: serviceId, action: action })
    });
    const data = await res.json();
    if (data.success) {
      showToast(`✅ ${data.message}`, 'success');
      if (data.data) {
        state.services = data.data.services || [];
        state.system = data.data.system || null;
        updateTelemetry(data.data);
        renderCards();
      }
    } else {
      showToast(`❌ Error: ${data.error || 'No se pudo realizar la acción'}`, 'error');
    }
  } catch (err) {
    showToast(`❌ Error de conexión: ${err.message}`, 'error');
  }
}

// Logs Viewer Modal
async function openLogsModal(serviceId, serviceName) {
  state.currentLogServiceId = serviceId;
  logModalTitle.textContent = `Logs: ${serviceName}`;
  logModalSub.textContent = `Servicio ID: ${serviceId}`;
  logsConsole.textContent = 'Cargando registros...';
  logsModal.style.display = 'flex';

  await refreshCurrentLogs();
}

async function refreshCurrentLogs() {
  if (!state.currentLogServiceId) return;
  try {
    const res = await fetch(`/api/service/logs?id=${state.currentLogServiceId}&lines=80`);
    const data = await res.json();
    logsConsole.textContent = data.logs || 'Sin registros.';
    logsConsole.scrollTop = logsConsole.scrollHeight;
  } catch (err) {
    logsConsole.textContent = 'Error cargando logs: ' + err.message;
  }
}

function clearConsoleView() {
  logsConsole.textContent = '[Vista de consola limpiada]';
}

function closeLogsModal() {
  logsModal.style.display = 'none';
  state.currentLogServiceId = null;
}

// Terminal Drawer
function toggleTerminal() {
  state.isTerminalOpen = !state.isTerminalOpen;
  terminalDrawer.classList.toggle('open', state.isTerminalOpen);
  if (state.isTerminalOpen) {
    termCmdInput.focus();
  }
}

async function executeTerminalCommand(e) {
  e.preventDefault();
  const cmd = termCmdInput.value.trim();
  if (!cmd) return;

  terminalOutput.textContent += `\nroot@pixel6a:~# ${cmd}\n`;
  termCmdInput.value = '';
  terminalOutput.scrollTop = terminalOutput.scrollHeight;

  try {
    const res = await fetch('/api/terminal/exec', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ command: cmd })
    });
    const data = await res.json();
    terminalOutput.textContent += (data.output || '(sin salida)') + '\n';
  } catch (err) {
    terminalOutput.textContent += `Error ejecutando comando: ${err.message}\n`;
  }
  terminalOutput.scrollTop = terminalOutput.scrollHeight;
}

// Toast System
function showToast(message, type = 'info') {
  const toast = document.createElement('div');
  toast.className = 'toast';
  toast.innerHTML = message;
  toastContainer.appendChild(toast);

  setTimeout(() => {
    toast.style.opacity = '0';
    toast.style.transform = 'translateY(10px)';
    toast.style.transition = 'all 0.3s ease';
    setTimeout(() => toast.remove(), 300);
  }, 3500);
}
