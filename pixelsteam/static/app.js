/* =========================================================
   PixelGlobal Deals - Frontend Logic & Interactivity v1.3
   ========================================================= */

const state = {
  currentTab: 'subs',
  deals: [],
  subscriptions: [],
  lastUpdated: '',
  favorites: JSON.parse(localStorage.getItem('pixelsteam_favs') || '[]'),
  searchTimeout: null
};

// DOM Elements
const searchInput = document.getElementById('searchInput');
const searchSubmitBtn = document.getElementById('searchSubmitBtn');
const clearSearchBtn = document.getElementById('clearSearchBtn');
const searchSuggestions = document.getElementById('searchSuggestions');
const gamesGrid = document.getElementById('gamesGrid');
const loader = document.getElementById('loader');
const sectionTitle = document.getElementById('sectionTitle');
const resultsCount = document.getElementById('resultsCount');
const tabButtons = document.querySelectorAll('.tab-btn');
const quickChips = document.querySelectorAll('.quick-chip');
const favCountSpan = document.getElementById('favCount');
const gameModal = document.getElementById('gameModal');
const modalContent = document.getElementById('modalContent');
const closeModalBtn = document.getElementById('closeModalBtn');

// Inicialización
document.addEventListener('DOMContentLoaded', () => {
  updateFavCount();
  loadSubscriptions();
  setupEventListeners();
});

// Manejador ultra-robusto de imágenes de Steam con multi-fallback
function handleSteamImgError(img, appid, name = 'Juego Steam') {
  const step = parseInt(img.dataset.step || '0', 10);
  
  if (step === 0) {
    img.dataset.step = '1';
    img.src = `https://shared.cloudflare.steamstatic.com/store_item_assets/steam/apps/${appid}/capsule_616x353.jpg`;
  } else if (step === 1) {
    img.dataset.step = '2';
    img.src = `https://cdn.akamai.steamstatic.com/steam/apps/${appid}/header.jpg`;
  } else if (step === 2) {
    img.dataset.step = '3';
    img.src = `https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/${appid}/capsule_184x69.jpg`;
  } else {
    img.onerror = null;
    // Placeholder estilizado SVG cyberpunk en caso de juego sin portada pública
    img.src = `data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="460" height="215" viewBox="0 0 460 215"><rect width="100%" height="100%" fill="%23141b29"/><circle cx="230" cy="90" r="36" fill="%231a9fff" opacity="0.15"/><path d="M218 80h24M230 68v24M215 98h30" stroke="%231a9fff" stroke-width="3" stroke-linecap="round"/><text x="50%" y="150" font-family="sans-serif" font-size="16" font-weight="bold" fill="%2394a3b8" text-anchor="middle">${encodeURIComponent(name.substring(0, 28))}</text></svg>`;
  }
}

function setupEventListeners() {
  searchInput.addEventListener('input', (e) => {
    const val = e.target.value.trim();
    clearSearchBtn.style.display = val ? 'block' : 'none';

    clearTimeout(state.searchTimeout);
    if (val.length >= 2) {
      state.searchTimeout = setTimeout(() => fetchSuggestions(val), 300);
    } else {
      searchSuggestions.style.display = 'none';
    }
  });

  searchInput.addEventListener('keydown', (e) => {
    if (e.key === 'Enter') {
      executeSearch(searchInput.value.trim());
    }
  });

  searchSubmitBtn.addEventListener('click', () => {
    executeSearch(searchInput.value.trim());
  });

  clearSearchBtn.addEventListener('click', () => {
    searchInput.value = '';
    clearSearchBtn.style.display = 'none';
    searchSuggestions.style.display = 'none';
    handleTabSwitch(state.currentTab);
  });

  document.addEventListener('click', (e) => {
    if (!e.target.closest('.search-wrapper')) {
      searchSuggestions.style.display = 'none';
    }
  });

  quickChips.forEach(chip => {
    chip.addEventListener('click', () => {
      const mode = chip.dataset.mode;
      const query = chip.dataset.query;

      if (mode === 'subs') {
        setActiveTab('subs');
      } else if (query) {
        searchInput.value = query;
        clearSearchBtn.style.display = 'block';
        executeSearch(query);
      }
    });
  });

  tabButtons.forEach(btn => {
    btn.addEventListener('click', () => {
      const tab = btn.dataset.tab;
      setActiveTab(tab);
    });
  });

  closeModalBtn.addEventListener('click', closeModal);
  gameModal.addEventListener('click', (e) => {
    if (e.target === gameModal) closeModal();
  });

  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') closeModal();
  });
}

function setActiveTab(tab) {
  tabButtons.forEach(b => b.classList.remove('active'));
  const target = document.querySelector(`.tab-btn[data-tab="${tab}"]`);
  if (target) target.classList.add('active');
  state.currentTab = tab;
  handleTabSwitch(tab);
}

function updateFavCount() {
  favCountSpan.textContent = state.favorites.length;
}

// Cargar Suscripciones
async function loadSubscriptions(forceRefresh = false) {
  showLoader(true);
  
  try {
    const url = forceRefresh ? '/api/subscriptions/refresh' : '/api/subscriptions';
    const res = await fetch(url);
    const data = await res.json();
    
    state.subscriptions = data.subscriptions || data;
    state.lastUpdated = data.last_updated || 'Hoy';

    sectionTitle.innerHTML = `
      <div style="display: flex; align-items: center; justify-content: space-between; width: 100%; flex-wrap: wrap; gap: 0.5rem;">
        <span><i class="fa-solid fa-credit-card"></i> Suscripciones Oficiales 2026</span>
        <button class="quick-chip" style="font-size: 0.75rem; color: var(--accent-green);" onclick="loadSubscriptions(true)" title="Forzar actualización de tasas de cambio">
          <i class="fa-solid fa-arrows-rotate"></i> Actualizado: ${state.lastUpdated}
        </button>
      </div>
    `;

    renderSubscriptions(state.subscriptions);
    resultsCount.textContent = `${state.subscriptions.length} plataformas comparadas en vivo`;
  } catch (err) {
    console.error(err);
    gamesGrid.innerHTML = `<div class="error-msg">Error al cargar las suscripciones.</div>`;
  } finally {
    showLoader(false);
  }
}

// Renderizar tarjetas de suscripciones
function renderSubscriptions(subs) {
  if (!subs || subs.length === 0) {
    gamesGrid.innerHTML = `<p>No hay suscripciones disponibles.</p>`;
    return;
  }

  gamesGrid.innerHTML = subs.map(sub => {
    const cheapest = sub.cheapest_region;
    const isFav = state.favorites.some(f => f.id === sub.id);

    return `
      <div class="sub-card" onclick="openSubscriptionModal('${sub.id}')">
        <button class="fav-btn ${isFav ? 'active' : ''}" title="Guardar en favoritos" onclick="toggleFavorite(event, ${JSON.stringify(sub).replace(/"/g, '&quot;')})">
          <i class="fa-${isFav ? 'solid' : 'regular'} fa-star"></i>
        </button>

        <div class="sub-header-banner" style="background: linear-gradient(135deg, ${sub.color}40, #141b29);">
          <img src="${sub.image}" alt="${sub.name}" onerror="this.style.display='none'">
          <span class="sub-badge-category">${sub.category}</span>
          <div class="sub-icon-badge" style="background: ${sub.color};">
            <i class="${sub.icon}"></i>
          </div>
        </div>

        <div class="sub-body">
          <h4 class="sub-title">${sub.name}</h4>
          
          <div class="sub-price-comparison">
            <div class="price-row-compare">
              <span class="label">🇪🇸 España (Oficial):</span>
              <span class="val-spain">${sub.spain_price.toFixed(2)}€ / mes</span>
            </div>
            <div class="price-row-compare">
              <span class="label">${cheapest ? cheapest.flag + ' ' + cheapest.region : 'Más barato'}:</span>
              <span class="val-cheapest">${cheapest ? cheapest.eur_price.toFixed(2) + '€ / mes' : '-'}</span>
            </div>
          </div>

          <div class="sub-saving-banner">
            <i class="fa-solid fa-piggy-bank"></i> Ahorras ${cheapest ? cheapest.saved_pct : 0}% (¡${sub.yearly_saving.toFixed(2)}€ al año!)
          </div>

          <div class="card-footer" style="padding-top: 1rem;">
            <span style="font-size: 0.8rem; color: var(--text-muted);">${sub.notes.substring(0, 45)}...</span>
            <div class="card-btn">
              <span>Comparar</span>
              <i class="fa-solid fa-arrow-right"></i>
            </div>
          </div>
        </div>
      </div>
    `;
  }).join('');
}

// Modal de Suscripción
function openSubscriptionModal(subId) {
  const sub = state.subscriptions.find(s => s.id === subId);
  if (!sub) return;

  searchSuggestions.style.display = 'none';
  gameModal.style.display = 'flex';
  document.body.style.overflow = 'hidden';

  const cheapest = sub.cheapest_region;

  modalContent.innerHTML = `
    <!-- Header Hero -->
    <div class="modal-header-hero">
      <div style="width: 120px; height: 120px; border-radius: var(--radius-md); background: ${sub.color}; display: flex; align-items: center; justify-content: center; font-size: 3.5rem; color: white; box-shadow: var(--shadow-lg);">
        <i class="${sub.icon}"></i>
      </div>
      <div class="modal-info">
        <h3 class="modal-title">${sub.name}</h3>
        <div class="modal-meta">
          <span class="meta-chip score"><i class="fa-solid fa-bolt"></i> ${sub.category}</span>
          <span class="meta-chip"><i class="fa-solid fa-piggy-bank"></i> Ahorro Anual: ~${sub.yearly_saving.toFixed(2)}€</span>
          <span class="meta-chip"><i class="fa-solid fa-arrows-rotate"></i> Actualizado: ${state.lastUpdated}</span>
        </div>
        <p class="modal-desc">${sub.notes}</p>
      </div>
    </div>

    <!-- Banner de Región Más Barata -->
    ${cheapest && cheapest.saved_pct > 0 ? `
      <div class="best-region-banner">
        <div class="best-region-left">
          <h4><i class="fa-solid fa-trophy"></i> Mejor Precio Global</h4>
          <div class="best-region-name">
            <span class="flag-icon">${cheapest.flag}</span>
            <span>${cheapest.region}</span>
          </div>
        </div>
        <div class="best-region-right">
          <div class="best-price-highlight">${cheapest.eur_price.toFixed(2)}€ <span style="font-size: 0.9rem; font-weight: normal;">/ mes</span></div>
          <div class="savings-highlight">¡Ahorras un ${cheapest.saved_pct}% (${cheapest.saved_eur.toFixed(2)}€ menos cada mes)!</div>
        </div>
      </div>
    ` : ''}

    <!-- Tabla Comparativa de Precios por País -->
    <h4 class="table-header-title"><i class="fa-solid fa-earth-americas"></i> Comparativa de Precios Oficiales por País</h4>
    <div class="regional-table-wrapper">
      <table class="regional-table">
        <thead>
          <tr>
            <th>País / Región</th>
            <th>Precio Local</th>
            <th>Precio en EUR (€)</th>
            <th>Ahorro vs España</th>
          </tr>
        </thead>
        <tbody>
          ${(sub.regional_prices || []).map(r => `
            <tr class="${r.region === cheapest.region && r.saved_pct > 0 ? 'cheapest-row' : ''} ${r.region.includes('España') ? 'spain-row' : ''}">
              <td>
                <div class="region-cell">
                  <span class="flag-icon">${r.flag}</span>
                  <span>${r.region}</span>
                  ${r.region.includes('España') ? '<span style="font-size: 0.75rem; color: var(--accent-blue); font-weight: 700;">(Oficial)</span>' : ''}
                </div>
              </td>
              <td>${r.local_amount.toFixed(2)} ${r.currency} / mes</td>
              <td class="price-eur-cell" style="color: ${r.region === cheapest.region ? 'var(--accent-green)' : 'var(--text-main)'};">
                ${r.eur_price.toFixed(2)}€ / mes
              </td>
              <td>
                ${r.saved_pct > 0 
                  ? `<span class="savings-badge">-${r.saved_pct}% (-${r.saved_eur.toFixed(2)}€/mes)</span>` 
                  : `<span class="savings-badge zero">-</span>`
                }
              </td>
            </tr>
          `).join('')}
        </tbody>
      </table>
    </div>
  `;
}

// Cargar ofertas de Steam
async function loadFeaturedDeals() {
  showLoader(true);
  sectionTitle.innerHTML = '<i class="fa-solid fa-fire-flame-curved"></i> Top Chollos y Ofertas de Steam';
  
  try {
    const res = await fetch('/api/deals');
    const deals = await res.json();
    state.deals = deals;
    renderGames(deals);
    resultsCount.textContent = `${deals.length} ofertas destacadas`;
  } catch (err) {
    console.error(err);
    gamesGrid.innerHTML = `<div class="error-msg">Error al cargar las ofertas de Steam.</div>`;
  } finally {
    showLoader(false);
  }
}

// Sugerencias de búsqueda
async function fetchSuggestions(query) {
  try {
    const res = await fetch(`/api/search?q=${encodeURIComponent(query)}`);
    const items = await res.json();

    const matchingSubs = state.subscriptions.filter(s => 
      s.name.toLowerCase().includes(query.toLowerCase()) || 
      s.category.toLowerCase().includes(query.toLowerCase())
    );

    let html = '';

    matchingSubs.forEach(s => {
      html += `
        <div class="suggestion-item" onclick="openSubscriptionModal('${s.id}')">
          <div style="width: 40px; height: 40px; border-radius: 4px; background: ${s.color}; display: flex; align-items: center; justify-content: center; color: white;">
            <i class="${s.icon}"></i>
          </div>
          <div class="suggestion-info">
            <div class="suggestion-name">${s.name}</div>
            <div class="suggestion-price">Desde ${s.cheapest_region.eur_price.toFixed(2)}€/mes <span class="suggestion-badge">SUSCRIPCIÓN</span></div>
          </div>
          <i class="fa-solid fa-chevron-right" style="color: var(--text-dark); font-size: 0.8rem;"></i>
        </div>
      `;
    });

    if (items && items.length > 0) {
      items.slice(0, 5).forEach(item => {
        const imgSrc = item.header_image || item.image;
        html += `
          <div class="suggestion-item" onclick="openGameModal(${item.id})">
            <img src="${imgSrc}" class="suggestion-img" alt="${item.name}" onerror="handleSteamImgError(this, ${item.id}, '${item.name.replace(/'/g, "\\'")}')">
            <div class="suggestion-info">
              <div class="suggestion-name">${item.name}</div>
              <div class="suggestion-price">
                ${item.price_es > 0 ? item.price_es.toFixed(2) + '€' : 'Gratis'}
                ${item.discount > 0 ? `<span class="suggestion-badge">-${item.discount}%</span>` : ''}
              </div>
            </div>
            <i class="fa-solid fa-chevron-right" style="color: var(--text-dark); font-size: 0.8rem;"></i>
          </div>
        `;
      });
    }

    if (!html) {
      searchSuggestions.style.display = 'none';
      return;
    }

    searchSuggestions.innerHTML = html;
    searchSuggestions.style.display = 'block';
  } catch (err) {
    console.error(err);
  }
}

// Búsqueda completa
async function executeSearch(query) {
  if (!query) return;
  searchSuggestions.style.display = 'none';
  showLoader(true);
  sectionTitle.innerHTML = `<i class="fa-solid fa-magnifying-glass"></i> Resultados para "${query}"`;

  try {
    const res = await fetch(`/api/search?q=${encodeURIComponent(query)}`);
    const results = await res.json();
    renderGames(results);
    resultsCount.textContent = `${results.length} juegos encontrados`;
  } catch (err) {
    console.error(err);
    gamesGrid.innerHTML = `<div class="error-msg">Error al buscar.</div>`;
  } finally {
    showLoader(false);
  }
}

// Renderizar tarjetas de juegos
function renderGames(games) {
  if (!games || games.length === 0) {
    gamesGrid.innerHTML = `
      <div style="grid-column: 1 / -1; text-align: center; padding: 3rem 1rem; color: var(--text-muted);">
        <i class="fa-solid fa-gamepad" style="font-size: 3rem; margin-bottom: 1rem; color: var(--text-dark);"></i>
        <h4>No se han encontrado juegos</h4>
        <p>Prueba con otro término de búsqueda.</p>
      </div>
    `;
    return;
  }

  gamesGrid.innerHTML = games.map(game => {
    const isFav = state.favorites.some(f => f.id === game.id);
    const finalPrice = game.final_price !== undefined ? game.final_price : game.price_es;
    const origPrice = game.original_price !== undefined ? game.original_price : game.original_price_es;
    const discount = game.discount || 0;
    const isFree = finalPrice === 0;
    const mainImg = game.header_image || game.image || `https://shared.cloudflare.steamstatic.com/store_item_assets/steam/apps/${game.id}/header.jpg`;

    return `
      <div class="game-card" onclick="openGameModal(${game.id})">
        <button class="fav-btn ${isFav ? 'active' : ''}" title="Guardar en favoritos" onclick="toggleFavorite(event, ${JSON.stringify(game).replace(/"/g, '&quot;')})">
          <i class="fa-${isFav ? 'solid' : 'regular'} fa-star"></i>
        </button>

        <div class="card-img-wrapper">
          <img src="${mainImg}" alt="${game.name}" loading="lazy" onerror="handleSteamImgError(this, ${game.id}, '${game.name.replace(/'/g, "\\'")}')">
          ${discount > 0 ? `<div class="discount-badge">-${discount}%</div>` : ''}
        </div>

        <div class="card-body">
          <h4 class="card-title" title="${game.name}">${game.name}</h4>
          
          <div class="card-footer">
            <div class="price-box">
              ${discount > 0 && origPrice > 0 ? `<span class="orig-price">${origPrice.toFixed(2)}€</span>` : ''}
              <span class="final-price ${isFree ? 'free' : ''}">
                ${isFree ? 'GRATIS' : (finalPrice !== undefined ? finalPrice.toFixed(2) + '€' : 'Ver precio')}
              </span>
            </div>
            <div class="card-btn">
              <span>Comparar</span>
              <i class="fa-solid fa-arrow-right"></i>
            </div>
          </div>
        </div>
      </div>
    `;
  }).join('');
}

// Modal de detalles y comparador regional de juegos
async function openGameModal(appid) {
  searchSuggestions.style.display = 'none';
  gameModal.style.display = 'flex';
  document.body.style.overflow = 'hidden';

  modalContent.innerHTML = `
    <div class="loader-container">
      <div class="spinner"></div>
      <p style="font-weight: 600;">Consultando precios en vivo en 9 regiones del mundo...</p>
      <p style="font-size: 0.85rem; color: var(--text-muted); margin-top: 0.5rem;">España 🇪🇸 &bull; Ucrania 🇺🇦 &bull; Kazajistán 🇰🇿 &bull; Turquía 🇹🇷 &bull; Argentina 🇦🇷 &bull; China 🇨🇳</p>
    </div>
  `;

  try {
    const res = await fetch(`/api/game/${appid}`);
    const data = await res.json();

    if (data.error) {
      modalContent.innerHTML = `<div class="error-msg">${data.error}</div>`;
      return;
    }

    renderGameModalContent(data);
  } catch (err) {
    console.error(err);
    modalContent.innerHTML = `<div class="error-msg">Error al conectar con la API de Steam.</div>`;
  }
}

function renderGameModalContent(game) {
  const cheapest = game.cheapest_region;
  const headerImg = game.header_image || `https://shared.cloudflare.steamstatic.com/store_item_assets/steam/apps/${game.id}/header.jpg`;

  modalContent.innerHTML = `
    <div class="modal-header-hero">
      <img src="${headerImg}" class="modal-poster" alt="${game.name}" onerror="handleSteamImgError(this, ${game.id}, '${game.name.replace(/'/g, "\\'")}')">
      <div class="modal-info">
        <h3 class="modal-title">${game.name}</h3>
        <div class="modal-meta">
          ${game.metacritic ? `<span class="meta-chip score"><i class="fa-solid fa-award"></i> Metacritic ${game.metacritic}</span>` : ''}
          ${game.release_date ? `<span class="meta-chip"><i class="fa-regular fa-calendar"></i> ${game.release_date}</span>` : ''}
          ${(game.genres || []).map(g => `<span class="meta-chip">${g}</span>`).join('')}
        </div>
        <p class="modal-desc">${game.short_description || 'Sin descripción disponible.'}</p>
      </div>
    </div>

    ${cheapest && cheapest.saved_pct > 0 ? `
      <div class="best-region-banner">
        <div class="best-region-left">
          <h4><i class="fa-solid fa-trophy"></i> Mejor Precio Global</h4>
          <div class="best-region-name">
            <span class="flag-icon">${cheapest.flag}</span>
            <span>${cheapest.region}</span>
          </div>
        </div>
        <div class="best-region-right">
          <div class="best-price-highlight">${cheapest.price_eur.toFixed(2)}€</div>
          <div class="savings-highlight">¡Ahorras un ${cheapest.saved_pct}% (${cheapest.saved_eur.toFixed(2)}€ menos que en España)!</div>
        </div>
      </div>
    ` : ''}

    <h4 class="table-header-title"><i class="fa-solid fa-earth-americas"></i> Comparativa de Precios Oficiales por Región</h4>
    <div class="regional-table-wrapper">
      <table class="regional-table">
        <thead>
          <tr>
            <th>País / Región</th>
            <th>Precio Local</th>
            <th>Precio en EUR (€)</th>
            <th>Ahorro vs España</th>
          </tr>
        </thead>
        <tbody>
          ${(game.regional_prices || []).map(r => `
            <tr class="${r.code === cheapest.code && r.saved_pct > 0 ? 'cheapest-row' : ''} ${r.code === 'es' ? 'spain-row' : ''}">
              <td>
                <div class="region-cell">
                  <span class="flag-icon">${r.flag}</span>
                  <span>${r.region}</span>
                  ${r.code === 'es' ? '<span style="font-size: 0.75rem; color: var(--accent-blue); font-weight: 700;">(Local)</span>' : ''}
                </div>
              </td>
              <td>${r.is_free ? 'Gratis' : r.price_local.toFixed(2) + ' ' + r.currency}</td>
              <td class="price-eur-cell" style="color: ${r.code === cheapest.code ? 'var(--accent-green)' : 'var(--text-main)'};">
                ${r.is_free ? 'GRATIS' : r.price_eur.toFixed(2) + '€'}
              </td>
              <td>
                ${r.saved_pct > 0 
                  ? `<span class="savings-badge">-${r.saved_pct}% (${r.saved_eur.toFixed(2)}€)</span>` 
                  : `<span class="savings-badge zero">-</span>`
                }
              </td>
            </tr>
          `).join('')}
        </tbody>
      </table>
    </div>

    <a href="${game.steam_url}" target="_blank" class="steam-direct-btn">
      <i class="fa-brands fa-steam"></i>
      <span>Abrir en la Tienda Oficial de Steam</span>
      <i class="fa-solid fa-arrow-up-right-from-square"></i>
    </a>
  `;
}

function closeModal() {
  gameModal.style.display = 'none';
  document.body.style.overflow = 'auto';
}

function showLoader(show) {
  loader.style.display = show ? 'block' : 'none';
  if (show) gamesGrid.style.display = 'none';
  else gamesGrid.style.display = 'grid';
}

// Favoritos
function toggleFavorite(e, item) {
  e.stopPropagation();
  const idx = state.favorites.findIndex(f => f.id === item.id);
  
  if (idx >= 0) {
    state.favorites.splice(idx, 1);
  } else {
    state.favorites.push(item);
  }

  localStorage.setItem('pixelsteam_favs', JSON.stringify(state.favorites));
  updateFavCount();

  const btn = e.currentTarget;
  const isFav = idx < 0;
  btn.classList.toggle('active', isFav);
  btn.innerHTML = `<i class="fa-${isFav ? 'solid' : 'regular'} fa-star"></i>`;

  if (state.currentTab === 'favorites') {
    handleTabSwitch('favorites');
  }
}

// Cambio de pestaña
function handleTabSwitch(tab) {
  if (tab === 'subs') {
    loadSubscriptions();
  } else if (tab === 'deals') {
    loadFeaturedDeals();
  } else if (tab === 'under5') {
    sectionTitle.innerHTML = '<i class="fa-solid fa-tags"></i> Juegos por menos de 5€ / 10€';
    const filtered = state.deals.filter(d => d.final_price <= 10.0);
    renderGames(filtered);
    resultsCount.textContent = `${filtered.length} juegos en oferta`;
  } else if (tab === 'favorites') {
    sectionTitle.innerHTML = '<i class="fa-solid fa-star"></i> Mi Lista de Favoritos';
    renderGames(state.favorites);
    resultsCount.textContent = `${state.favorites.length} guardados`;
  }
}
