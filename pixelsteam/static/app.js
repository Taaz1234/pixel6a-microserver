/* =========================================================
   PixelSteam Deals - Frontend Logic & Interactivity
   ========================================================= */

const state = {
  currentTab: 'deals',
  deals: [],
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
  loadFeaturedDeals();
  setupEventListeners();
});

function setupEventListeners() {
  // Búsqueda en vivo con debounce
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
    if (state.currentTab === 'deals') loadFeaturedDeals();
  });

  // Cerrar sugerencias al hacer clic fuera
  document.addEventListener('click', (e) => {
    if (!e.target.closest('.search-wrapper')) {
      searchSuggestions.style.display = 'none';
    }
  });

  // Quick Chips
  quickChips.forEach(chip => {
    chip.addEventListener('click', () => {
      const q = chip.dataset.query;
      searchInput.value = q;
      clearSearchBtn.style.display = 'block';
      executeSearch(q);
    });
  });

  // Tabs
  tabButtons.forEach(btn => {
    btn.addEventListener('click', () => {
      tabButtons.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      const tab = btn.dataset.tab;
      state.currentTab = tab;
      handleTabSwitch(tab);
    });
  });

  // Modal Close
  closeModalBtn.addEventListener('click', closeModal);
  gameModal.addEventListener('click', (e) => {
    if (e.target === gameModal) closeModal();
  });

  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') closeModal();
  });
}

function updateFavCount() {
  favCountSpan.textContent = state.favorites.length;
}

// Cargar ofertas destacadas
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
    gamesGrid.innerHTML = `<div class="error-msg">Error al cargar las ofertas de Steam. Inténtalo de nuevo.</div>`;
  } finally {
    showLoader(false);
  }
}

// Sugerencias de búsqueda
async function fetchSuggestions(query) {
  try {
    const res = await fetch(`/api/search?q=${encodeURIComponent(query)}`);
    const items = await res.json();

    if (!items || items.length === 0) {
      searchSuggestions.style.display = 'none';
      return;
    }

    searchSuggestions.innerHTML = items.slice(0, 6).map(item => `
      <div class="suggestion-item" onclick="openGameModal(${item.id})">
        <img src="${item.header_image}" class="suggestion-img" alt="${item.name}" onerror="this.src='${item.image}'">
        <div class="suggestion-info">
          <div class="suggestion-name">${item.name}</div>
          <div class="suggestion-price">
            ${item.price_es > 0 ? item.price_es.toFixed(2) + '€' : 'Gratis'}
            ${item.discount > 0 ? `<span class="suggestion-badge">-${item.discount}%</span>` : ''}
          </div>
        </div>
        <i class="fa-solid fa-chevron-right" style="color: var(--text-dark); font-size: 0.8rem;"></i>
      </div>
    `).join('');

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
    gamesGrid.innerHTML = `<div class="error-msg">Error al buscar en Steam.</div>`;
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

    return `
      <div class="game-card" onclick="openGameModal(${game.id})">
        <button class="fav-btn ${isFav ? 'active' : ''}" title="Guardar en favoritos" onclick="toggleFavorite(event, ${JSON.stringify(game).replace(/"/g, '&quot;')})">
          <i class="fa-${isFav ? 'solid' : 'regular'} fa-star"></i>
        </button>

        <div class="card-img-wrapper">
          <img src="${game.header_image || game.image}" alt="${game.name}" loading="lazy">
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

// Modal de detalles y comparador regional
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

    renderModalContent(data);
  } catch (err) {
    console.error(err);
    modalContent.innerHTML = `<div class="error-msg">Error al conectar con la API de Steam.</div>`;
  }
}

function renderModalContent(game) {
  const cheapest = game.cheapest_region;
  const priceEs = game.price_es;

  modalContent.innerHTML = `
    <!-- Header Hero -->
    <div class="modal-header-hero">
      <img src="${game.header_image}" class="modal-poster" alt="${game.name}">
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
          <div class="best-price-highlight">${cheapest.price_eur.toFixed(2)}€</div>
          <div class="savings-highlight">¡Ahorras un ${cheapest.saved_pct}% (${cheapest.saved_eur.toFixed(2)}€ menos que en España)!</div>
        </div>
      </div>
    ` : ''}

    <!-- Tabla Comparativa de Precios Regionales -->
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

    <!-- Botón directo a Steam -->
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
function toggleFavorite(e, game) {
  e.stopPropagation();
  const idx = state.favorites.findIndex(f => f.id === game.id);
  
  if (idx >= 0) {
    state.favorites.splice(idx, 1);
  } else {
    state.favorites.push(game);
  }

  localStorage.setItem('pixelsteam_favs', JSON.stringify(state.favorites));
  updateFavCount();

  // Actualizar UI
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
  if (tab === 'deals') {
    loadFeaturedDeals();
  } else if (tab === 'under5') {
    sectionTitle.innerHTML = '<i class="fa-solid fa-tags"></i> Juegos por menos de 5€ / 10€';
    const filtered = state.deals.filter(d => d.final_price <= 10.0);
    renderGames(filtered);
    resultsCount.textContent = `${filtered.length} juegos en oferta`;
  } else if (tab === 'favorites') {
    sectionTitle.innerHTML = '<i class="fa-solid fa-star"></i> Mi Lista de Juegos Favoritos';
    renderGames(state.favorites);
    resultsCount.textContent = `${state.favorites.length} juegos guardados`;
  }
}
