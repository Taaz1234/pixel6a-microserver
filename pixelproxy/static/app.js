// PixelProxy & PixelTunnel Pro - Client Controller

const state = {
  hosts: [],
  tunnels: [],
  traffic: null,
  activeTab: 'hosts',
  currentQrCodeObj: null
};

// DOM Elements
const hostsTableBody = document.getElementById('hostsTableBody');
const tunnelsGrid = document.getElementById('tunnelsGrid');
const trafficLogsBody = document.getElementById('trafficLogsBody');

const hostsCountVal = document.getElementById('hostsCountVal');
const tunnelsCountVal = document.getElementById('tunnelsCountVal');
const totalReqVal = document.getElementById('totalReqVal');
const avgLatVal = document.getElementById('avgLatVal');

const hostsBadge = document.getElementById('hostsBadge');
const tunnelsBadge = document.getElementById('tunnelsBadge');

const stat2xxVal = document.getElementById('stat2xxVal');
const stat4xxVal = document.getElementById('stat4xxVal');
const stat5xxVal = document.getElementById('stat5xxVal');
const statAvgLatVal = document.getElementById('statAvgLatVal');

const hostModal = document.getElementById('hostModal');
const qrModal = document.getElementById('qrModal');
const qrcodeContainer = document.getElementById('qrcodeContainer');
const qrServiceTitle = document.getElementById('qrServiceTitle');
const qrUrlInput = document.getElementById('qrUrlInput');
const toastContainer = document.getElementById('toastContainer');

// Init
document.addEventListener('DOMContentLoaded', () => {
  fetchAllData();
  setInterval(() => {
    fetchAllData();
  }, 3500);
});

async function fetchAllData() {
  await Promise.all([fetchHosts(), fetchTunnels(), fetchTraffic()]);
}

// Tab Switching
function switchMainTab(tabName) {
  state.activeTab = tabName;
  
  document.getElementById('tabHostsBtn').classList.toggle('active', tabName === 'hosts');
  document.getElementById('tabTunnelsBtn').classList.toggle('active', tabName === 'tunnels');
  document.getElementById('tabTrafficBtn').classList.toggle('active', tabName === 'traffic');

  document.getElementById('hostsPane').style.display = tabName === 'hosts' ? 'block' : 'none';
  document.getElementById('tunnelsPane').style.display = tabName === 'tunnels' ? 'block' : 'none';
  document.getElementById('trafficPane').style.display = tabName === 'traffic' ? 'block' : 'none';
}

// 1. Fetch Hosts
async function fetchHosts() {
  try {
    const res = await fetch('/api/proxy/hosts');
    if (!res.ok) return;
    const hosts = await res.json();
    state.hosts = hosts;

    hostsCountVal.textContent = hosts.length;
    hostsBadge.textContent = hosts.length;

    renderHostsTable(hosts);
  } catch (e) {
    console.error('Error fetching hosts:', e);
  }
}

function renderHostsTable(hosts) {
  if (!hostsTableBody) return;
  if (hosts.length === 0) {
    hostsTableBody.innerHTML = `<tr><td colspan="8" style="text-align:center; padding: 2rem; color: var(--text-muted);">No hay proxy hosts configurados.</td></tr>`;
    return;
  }

  hostsTableBody.innerHTML = hosts.map(h => `
    <tr>
      <td class="service-cell">${h.name}</td>
      <td><span class="domain-chip">${h.domain}</span></td>
      <td><span class="path-chip">${h.path_prefix}</span></td>
      <td><span class="target-text">${h.target_url}</span></td>
      <td><span class="badge-bool ${h.ssl_enabled ? 'yes' : 'no'}">${h.ssl_enabled ? 'HTTPS (SSL)' : 'HTTP'}</span></td>
      <td><span class="badge-bool ${h.websocket_enabled ? 'yes' : 'no'}">${h.websocket_enabled ? 'Activado' : 'Desactivado'}</span></td>
      <td><span style="color: var(--accent-emerald); font-weight: 700;"><i class="fa-solid fa-circle" style="font-size: 0.5rem;"></i> Activo</span></td>
      <td>
        <div style="display: flex; gap: 0.35rem;">
          <a href="/proxy/${h.id}/" target="_blank" class="action-icon-btn" title="Probar ruta de Proxy">
            <i class="fa-solid fa-arrow-up-right-from-square text-cyan"></i>
          </a>
          <button class="action-icon-btn" onclick="deleteHost('${h.id}')" title="Eliminar host">
            <i class="fa-solid fa-trash-can text-rose"></i>
          </button>
        </div>
      </td>
    </tr>
  `).join('');
}

// 2. Fetch Tunnels
async function fetchTunnels() {
  try {
    const res = await fetch('/api/tunnel/list');
    if (!res.ok) return;
    const tunnels = await res.json();
    state.tunnels = tunnels;

    tunnelsCountVal.textContent = tunnels.length;
    tunnelsBadge.textContent = tunnels.length;

    renderTunnelsGrid(tunnels);
  } catch (e) {
    console.error('Error fetching tunnels:', e);
  }
}

function renderTunnelsGrid(tunnels) {
  if (!tunnelsGrid) return;
  if (tunnels.length === 0) {
    tunnelsGrid.innerHTML = `
      <div style="grid-column: 1/-1; text-align: center; padding: 2.5rem; background: var(--bg-card); border: 1px dashed var(--border-color); border-radius: var(--radius-md); color: var(--text-muted);">
        <i class="fa-solid fa-cloud-bolt" style="font-size: 2rem; color: var(--accent-orange); margin-bottom: 0.5rem; opacity: 0.6;"></i>
        <p>No hay túneles públicos activos en este momento.<br>Selecciona un servicio arriba y pulsa <strong>"Generar Enlace Seguro"</strong>.</p>
      </div>
    `;
    return;
  }

  tunnelsGrid.innerHTML = tunnels.map(t => `
    <div class="tunnel-card">
      <div class="tunnel-header">
        <div>
          <h4 style="color: #fff; font-size: 1.05rem;">${t.service_name}</h4>
          <span style="font-size: 0.75rem; color: var(--text-muted);">Puerto Local: <strong>:${t.local_port}</strong> &bull; ${t.provider.toUpperCase()}</span>
        </div>
        <span style="background: rgba(16, 185, 129, 0.15); color: var(--accent-emerald); border: 1px solid rgba(16, 185, 129, 0.4); padding: 0.2rem 0.55rem; border-radius: var(--radius-full); font-size: 0.72rem; font-weight: 800;">
          <i class="fa-solid fa-shield-halved"></i> HTTPS EN VIVO
        </span>
      </div>

      <div class="tunnel-url-box">${t.public_url}</div>

      <div class="tunnel-actions">
        <a href="${t.public_url}" target="_blank" class="action-btn" style="background: rgba(6, 182, 212, 0.15); border-color: rgba(6, 182, 212, 0.4); color: var(--accent-cyan);">
          <i class="fa-solid fa-globe"></i> Abrir
        </a>
        <button class="action-btn" onclick="openQrModal('${t.service_name}', '${t.public_url}')">
          <i class="fa-solid fa-qrcode text-gold"></i> Ver QR
        </button>
        <button class="action-btn" style="background: rgba(244, 63, 94, 0.15); border-color: rgba(244, 63, 94, 0.4); color: var(--accent-rose);" onclick="stopTunnel('${t.id}')">
          <i class="fa-solid fa-stop"></i> Detener
        </button>
      </div>
    </div>
  `).join('');
}

// 3. Fetch Traffic
async function fetchTraffic() {
  try {
    const res = await fetch('/api/proxy/traffic');
    if (!res.ok) return;
    const data = await res.json();
    state.traffic = data;

    totalReqVal.textContent = data.total_requests;
    avgLatVal.textContent = `${data.avg_latency_ms} ms`;

    stat2xxVal.textContent = data.status_2xx;
    stat4xxVal.textContent = data.status_4xx;
    stat5xxVal.textContent = data.status_5xx;
    statAvgLatVal.textContent = `${data.avg_latency_ms} ms`;

    renderTrafficLogs(data.recent_logs || []);
  } catch (e) {
    console.error('Error fetching traffic:', e);
  }
}

function renderTrafficLogs(logs) {
  if (!trafficLogsBody) return;
  if (logs.length === 0) {
    trafficLogsBody.innerHTML = `<tr><td colspan="7" style="text-align:center; padding: 2rem; color: var(--text-muted);">Esperando peticiones de tráfico en el proxy...</td></tr>`;
    return;
  }

  trafficLogsBody.innerHTML = logs.map(l => {
    let codeClass = 'code-2xx';
    if (l.status >= 400 && l.status < 500) codeClass = 'code-4xx';
    if (l.status >= 500) codeClass = 'code-5xx';

    return `
      <tr>
        <td style="color: var(--text-muted);">${l.timestamp}</td>
        <td><strong>${l.client_ip}</strong></td>
        <td><span style="color: var(--accent-cyan); font-weight: 700;">${l.method}</span></td>
        <td style="color: #fff;">${l.path}</td>
        <td style="color: var(--text-muted);">${l.target}</td>
        <td><span class="status-code ${codeClass}">${l.status}</span></td>
        <td style="color: var(--accent-emerald); font-weight: 600;">${l.latency_ms} ms</td>
      </tr>
    `;
  }).join('');
}

// Launch Tunnel Form
async function launchTunnel(e) {
  e.preventDefault();
  const select = document.getElementById('tunnelServiceSelect');
  const [serviceId, port, serviceName] = select.value.split(':');
  const provider = document.getElementById('tunnelProviderSelect').value;

  showToast(`⚡ Generando túnel seguro HTTPS con ${provider}...`, 'info');

  try {
    const res = await fetch('/api/tunnel/start', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        service_id: serviceId,
        service_name: serviceName,
        port: parseInt(port),
        provider: provider
      })
    });
    const data = await res.json();
    if (data.success) {
      showToast(`🚀 ¡Túnel Cloudflare activo con éxito!`, 'success');
      await fetchTunnels();
      openQrModal(serviceName, data.tunnel.public_url);
    }
  } catch (err) {
    showToast(`❌ Error: ${err.message}`, 'error');
  }
}

async function stopTunnel(tunnelId) {
  try {
    await fetch('/api/tunnel/stop', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ tunnel_id: tunnelId })
    });
    showToast(`🛑 Túnel detenido`, 'info');
    await fetchTunnels();
  } catch (err) {
    showToast(`Error: ${err.message}`, 'error');
  }
}

// QR Code Modal
function openQrModal(serviceName, publicUrl) {
  qrServiceTitle.textContent = serviceName;
  qrUrlInput.value = publicUrl;
  qrcodeContainer.innerHTML = '';

  state.currentQrCodeObj = new QRCode(qrcodeContainer, {
    text: publicUrl,
    width: 170,
    height: 170,
    colorDark: "#0b0f19",
    colorLight: "#ffffff",
    correctLevel: QRCode.CorrectLevel.M
  });

  qrModal.style.display = 'flex';
}

function closeQrModal() {
  qrModal.style.display = 'none';
}

function copyQrUrl() {
  navigator.clipboard.writeText(qrUrlInput.value);
  showToast('📋 ¡Enlace público copiado al portapapeles!', 'success');
}

// Add Host Modal
function openAddHostModal() {
  document.getElementById('hostIdInput').value = '';
  document.getElementById('hostNameInput').value = '';
  document.getElementById('hostDomainInput').value = '';
  document.getElementById('hostPathInput').value = '';
  document.getElementById('hostTargetInput').value = '';
  hostModal.style.display = 'flex';
}

function closeHostModal() {
  hostModal.style.display = 'none';
}

async function saveHostForm(e) {
  e.preventDefault();
  const hostData = {
    id: document.getElementById('hostIdInput').value || document.getElementById('hostNameInput').value.toLowerCase().replace(/\s+/g, '-'),
    name: document.getElementById('hostNameInput').value.trim(),
    domain: document.getElementById('hostDomainInput').value.trim(),
    path_prefix: document.getElementById('hostPathInput').value.trim(),
    target_url: document.getElementById('hostTargetInput').value.trim(),
    ssl_enabled: document.getElementById('hostSslInput').checked,
    websocket_enabled: document.getElementById('hostWsInput').checked,
    status: 'active'
  };

  try {
    const res = await fetch('/api/proxy/hosts', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(hostData)
    });
    const data = await res.json();
    if (data.success) {
      showToast('✅ Proxy host guardado con éxito', 'success');
      closeHostModal();
      await fetchHosts();
    }
  } catch (err) {
    showToast('❌ Error guardando host: ' + err.message, 'error');
  }
}

async function deleteHost(hostId) {
  if (!confirm('¿Eliminar este proxy host?')) return;
  try {
    await fetch('/api/proxy/hosts/delete', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ id: hostId })
    });
    showToast('🗑️ Host eliminado', 'info');
    await fetchHosts();
  } catch (err) {
    showToast('Error: ' + err.message, 'error');
  }
}

// Toast
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
