// Mobile Navbar Toggle
document.addEventListener('DOMContentLoaded', () => {
    const hamburger = document.querySelector('.hamburger');
    const navLinks = document.querySelector('.nav-links');
    
    if (hamburger && navLinks) {
        hamburger.addEventListener('click', () => {
            navLinks.classList.toggle('active');
        });
    }

    // Insert Loading Overlay if not present
    if (!document.getElementById('loading-overlay')) {
        const overlay = document.createElement('div');
        overlay.id = 'loading-overlay';
        overlay.innerHTML = '<div class="spinner"></div>';
        document.body.appendChild(overlay);
    }
    
    // Insert Toast Container if not present
    if (!document.getElementById('toast-container')) {
        const container = document.createElement('div');
        container.id = 'toast-container';
        document.body.appendChild(container);
    }

    // Active link highlighting
    const currentPath = window.location.pathname.split('/').pop();
    document.querySelectorAll('.nav-links a').forEach(link => {
        if (link.getAttribute('href') === currentPath) {
            link.classList.add('active');
        }
    });

    // Update Navbar based on auth state
    updateNavbar();
});

// Toast Notification System
function showToast(message, type = 'success') {
    const container = document.getElementById('toast-container');
    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    toast.textContent = message;
    
    container.appendChild(toast);
    
    setTimeout(() => {
        toast.style.opacity = '0';
        setTimeout(() => toast.remove(), 300);
    }, 3000);
}

// Authentication Guards and Utils
function requireAuth(role = null) {
    const token = sessionStorage.getItem('token');
    const userRole = sessionStorage.getItem('role');
    
    if (!token) {
        window.location.href = 'login.html';
        return false;
    }
    
    if (role && userRole !== role) {
        showToast('Unauthorized access', 'error');
        // redirect to respective dashboard
        if(userRole === 'citizen') window.location.href = 'citizen_dashboard.html';
        else if(userRole === 'official') window.location.href = 'official_dashboard.html';
        else if(userRole === 'admin') window.location.href = 'admin_dashboard.html';
        return false;
    }
    return true;
}

function updateNavbar() {
    const token = sessionStorage.getItem('token');
    const role = sessionStorage.getItem('role');
    const navLinks = document.querySelector('.nav-links');
    if (!navLinks) return;

    if (token) {
        let dashboardLink = '';
        if (role === 'citizen') dashboardLink = 'citizen_dashboard.html';
        if (role === 'official') dashboardLink = 'official_dashboard.html';
        if (role === 'admin') dashboardLink = 'admin_dashboard.html';

        navLinks.innerHTML = `
            <li><a href="index.html">Home</a></li>
            <li><a href="track_complaint.html">Track Complaint</a></li>
            <li><a href="${dashboardLink}">Dashboard</a></li>
            <li><a href="#" onclick="logout()">Logout</a></li>
        `;
    } else {
        navLinks.innerHTML = `
            <li><a href="index.html">Home</a></li>
            <li><a href="track_complaint.html">Track</a></li>
            <li><a href="login.html">Login</a></li>
            <li><a href="register.html" class="btn btn-primary" style="color:var(--primary-color)">Register</a></li>
        `;
    }
}

async function logout() {
    try {
        await apiFetch('/logout', 'POST');
    } catch(e) {} // Ignore error on logout
    sessionStorage.clear();
    window.location.href = 'index.html';
}

// Animated Counter (Intersection Observer)
function animateCounters() {
    const counters = document.querySelectorAll('.counter');
    const speed = 200;

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const counter = entry.target;
                const updateCount = () => {
                    const target = +counter.getAttribute('data-target');
                    const count = +counter.innerText;
                    const inc = target / speed;

                    if (count < target) {
                        counter.innerText = Math.ceil(count + inc);
                        setTimeout(updateCount, 1);
                    } else {
                        counter.innerText = target;
                    }
                };
                updateCount();
                observer.unobserve(counter);
            }
        });
    });

    counters.forEach(counter => observer.observe(counter));
}

// Modal Utils
function openModal(id) {
    document.getElementById(id).classList.add('active');
}
function closeModal(id) {
    document.getElementById(id).classList.remove('active');
}
