const BASE_URL = 'http://localhost:5000/api';

async function apiFetch(endpoint, method = 'GET', body = null) {
  const overlay = document.getElementById('loading-overlay');
  if (overlay) overlay.classList.add('active');

  const headers = {
    'Content-Type': 'application/json',
  };

  const token = sessionStorage.getItem('token');
  if (token) {
    headers['Authorization'] = `Bearer ${token}`; // standard format though backend currently checks session logic based on login
  }

  const config = {
    method,
    headers,
  };

  if (body) {
    config.body = JSON.stringify(body);
  }

  try {
    const response = await fetch(`${BASE_URL}${endpoint}`, config);
    const data = await response.json();

    if (!data.success) {
      throw new Error(data.error || 'API Error');
    }

    return data.data;
  } catch (error) {
    console.error('API Fetch Error:', error);
    if (typeof showToast === 'function') {
      showToast(error.message, 'error');
    }
    throw error;
  } finally {
    if (overlay) overlay.classList.remove('active');
  }
}
