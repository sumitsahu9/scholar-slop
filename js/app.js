/**
 * Scholar Slop - Application Controller
 */

const app = {
    state: {
        currentView: 'home',
        filters: {},
        selectedScholarshipId: null,
        userProfile: { name: '', state: '', category: '' }, // User Profile State
        bookmarks: [], // Array of scholarship IDs
        tracking: {}, // { scholarshipId: 'Planning' | 'Applied' | 'Missed' }
        recent: [] // Array of recently viewed IDs
    },

    init: () => {
        // Load data from LocalStorage
        app.loadUserData();
        // Check for saved theme or system preference
        const savedTheme = localStorage.getItem('theme');
        const systemPrefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;

        if (savedTheme === 'dark' || (!savedTheme && systemPrefersDark)) {
            document.body.classList.add('dark-mode');
        } else {
            document.body.classList.remove('dark-mode');
        }

        // If this is a pre-rendered static page, initialize states and bypass SPA routing
        if (window.isStaticPage) {
            app.initStaticPage();
            return;
        }

        // Add dynamic hash routing support for dashboard & home deep-linking
        const handleHashRoute = () => {
            const hash = window.location.hash;
            if (hash === '#dashboard') {
                app.showDashboard();
            } else if (hash === '#home' || !hash) {
                app.showHome();
            }
        };

        window.addEventListener('hashchange', handleHashRoute);
        handleHashRoute(); // Initialize routing
    },

    initStaticPage: () => {
        // Determine selected ID from container
        const staticContainer = document.getElementById('static-detail-container');
        const id = staticContainer ? staticContainer.dataset.id : null;
        app.state.selectedScholarshipId = id;
        app.state.currentView = 'detail';

        // Sync header bookmarks badge
        const savedCount = document.getElementById('saved-count');
        if (savedCount) {
            const count = app.state.bookmarks.length;
            savedCount.textContent = count;
            savedCount.style.display = count > 0 ? 'inline-block' : 'none';
        }

        if (id) {
            // Register page views
            app.addToRecent(id);

            // Sync bookmark button
            const isBookmarked = app.state.bookmarks.includes(id);
            const bookmarkBtn = document.getElementById('detail-bookmark-btn');
            if (bookmarkBtn) {
                bookmarkBtn.className = `btn-bookmark ${isBookmarked ? 'active' : ''}`;
                bookmarkBtn.innerHTML = '&#128278;'; // Unicode bookmark entity
            }

            // Sync application tracking status
            const trackingStatus = app.state.tracking[id] || 'none';
            const trackingOptions = document.querySelectorAll('.tracking-options .btn-tracking');
            trackingOptions.forEach(btn => {
                if (btn.textContent.trim() === trackingStatus) {
                    btn.classList.add('active');
                } else {
                    btn.classList.remove('active');
                }
            });
        }

        // Wire up authority page interactions (contact form, etc.)
        app.initAuthorityPage();
    },

    initAuthorityPage: () => {
        // Contact form submission handler
        const contactForm = document.getElementById('contact-form');
        if (contactForm) {
            contactForm.addEventListener('submit', (e) => {
                e.preventDefault();
                const name    = document.getElementById('cf-name')?.value.trim();
                const email   = document.getElementById('cf-email')?.value.trim();
                const message = document.getElementById('cf-message')?.value.trim();

                if (!name || !email || !message) {
                    alert('Please fill in all required fields before submitting.');
                    return;
                }

                // Show success toast
                const toast = document.getElementById('contact-toast');
                if (toast) {
                    toast.textContent = '✅ Message received! We typically respond within 48 hours.';
                    toast.classList.add('show');
                    setTimeout(() => toast.classList.remove('show'), 5000);
                }
                contactForm.reset();
            });
        }
    },

    populateDropdowns: () => {
        // Since templates are not in DOM yet, we wait for render or populate actively?
    },

    // --- Navigation ---

    showHome: () => {
        app.state.currentView = 'home';
        document.body.classList.add('home-bg'); // Add background for home
        app.renderView('view-home');

        // Populate States Datalist
        const stateList = document.getElementById('state-list');
        if (stateList) {
            const states = window.DataService.getAllStates();
            states.forEach(state => {
                const option = document.createElement('option');
                option.value = state;
                stateList.appendChild(option);
            });
        }
    },

    /**
     * Handles the Onboarding Form Submission
     */
    handleOnboarding: () => {
        const nameInput = document.getElementById('input-name');
        const stateSelect = document.getElementById('filter-state');
        const catSelect = document.getElementById('filter-category');
        const eduSelect = document.getElementById('filter-education');
        const incSelect = document.getElementById('filter-income');
        const instSelect = document.getElementById('filter-institute');

        const name = nameInput.value.trim();
        const state = stateSelect.value;
        const category = catSelect.value;
        const education = eduSelect.value;
        const income = incSelect.value;
        const institute = instSelect.value;

        if (!state || !category) {
            alert("Please select both your State and Category to find scholarships.");
            return;
        }

        // Save Profile
        app.state.userProfile = { name, state, category, education, income, institute };

        // Navigate to List
        app.showList({ state, category, education, income, institute });
    },

    showList: (filters) => {
        app.state.filters = filters;
        app.state.currentView = 'list';
        document.body.classList.remove('home-bg'); // Remove background
        app.renderView('view-list');

        // Use the new integrated filter/sort function
        app.applyResultsFiltersAndSort();

        // Personalize Greeting
        const greetingEl = document.getElementById('list-greeting');
        const subtitleEl = document.getElementById('list-subtitle');
        if (app.state.userProfile.name) {
            greetingEl.textContent = `Hello ${app.state.userProfile.name},`;
        } else {
            greetingEl.textContent = `Hello,`; // Default greeting if no name
        }

        // Update subtitle with criteria
        subtitleEl.textContent = `Showing scholarships for ${filters.category} students from ${filters.state}`;
    },

    showDetail: (id) => {
        app.state.selectedScholarshipId = id;
        app.state.currentView = 'detail';
        app.renderView('view-detail');
        app.renderScholarshipDetail(id);

        // Track recently viewed
        app.addToRecent(id);
    },

    goBackToList: () => {
        app.showList(app.state.filters); // Preserve filters
    },

    // --- Rendering Helpers ---

    renderView: (templateId) => {
        const main = document.getElementById('app-content');
        const template = document.getElementById(templateId);
        if (!main || !template) return;

        main.innerHTML = '';
        main.appendChild(template.content.cloneNode(true));

        // Scroll to top
        window.scrollTo(0, 0);
    },

    renderScholarshipList: (results) => {
        const listContainer = document.getElementById('scholarship-list');
        const noResults = document.getElementById('no-results');

        if (!listContainer) return;

        // Clear previous results
        listContainer.innerHTML = '';
        noResults.classList.add('hidden');

        if (results.length === 0) {
            noResults.classList.remove('hidden');
            return;
        }

        results.forEach(item => {
            const statusClass = item.calculatedStatus.toLowerCase().replace(' ', '-');
            const typeClass = item.Type.toLowerCase();

            // Bookmark State
            const isBookmarked = app.state.bookmarks.includes(item.id);
            const bookmarkClass = isBookmarked ? 'active' : '';

            // Tracking State
            const trackingStatus = app.state.tracking[item.id];
            const trackingBadge = trackingStatus ?
                `<div class="tracking-badge status-${trackingStatus.toLowerCase()}">${trackingStatus}</div>` : '';

            // Calculate Days Left
            const today = new Date();
            today.setHours(0, 0, 0, 0);
            const deadline = new Date(item.Deadline);
            const diffTime = deadline - today;
            const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

            let timeLeftText = "";
            if (isNaN(diffDays)) {
                timeLeftText = `📅 Deadline: ${item.Deadline}`;
            } else if (diffDays < 0) {
                timeLeftText = "Closed";
            } else if (diffDays === 0) {
                timeLeftText = "⏰ Ends Today";
            } else {
                timeLeftText = `⏰ ${diffDays} days left`;
            }

            const card = document.createElement('div');
            card.className = `scholarship-card ${statusClass}`;
            card.onclick = () => app.showDetail(item.id);

            card.innerHTML = `
                ${trackingBadge}
                <button class="btn-bookmark ${bookmarkClass}" onclick="app.toggleBookmark('${item.id}', event)" aria-label="Bookmark">
                    ${isBookmarked ? '🔖' : '🔖'}
                </button>
                <div class="card-badges">
                    <span class="badge ${statusClass}">${item.calculatedStatus}</span>
                    <span class="badge ${typeClass}">${item.Type}</span>
                </div>
                <h3>${item.Scholarship_Name}</h3>
                <div class="card-benefit">
                    <span class="benefit-label">Scholarship Benefit</span>
                    <span class="benefit-value">${item.Benefit_Amount}</span>
                </div>
                <div class="card-footer">
                    <div class="deadline-info">
                        ${timeLeftText}
                    </div>
                    <div class="btn-view">View Details</div>
                </div>
            `;
            listContainer.appendChild(card);
        });
    },

    renderScholarshipDetail: (id) => {
        const item = window.DataService.getById(id);
        if (!item) return;

        // Clear previous badges
        const badgesContainer = document.getElementById('detail-badges');
        if (badgesContainer) badgesContainer.innerHTML = '';

        // Clear previous list items
        document.getElementById('detail-eligibility').innerHTML = '';
        document.getElementById('detail-docs').innerHTML = '';

        // Fill Text Fields
        document.getElementById('detail-name').textContent = item.Scholarship_Name;
        document.getElementById('detail-state').textContent = item.State;
        document.getElementById('detail-category').textContent = item.Category;
        document.getElementById('detail-overview').textContent = item.Overview;
        document.getElementById('detail-benefit').textContent = item.Benefit_Type;
        document.getElementById('detail-benefit-value').textContent = item.Benefit_Amount || "As per norms";
        document.getElementById('detail-verified').textContent = app.formatDate(item.Last_Verified);

        const startEl = document.getElementById('detail-start');
        const deadlineEl = document.getElementById('detail-deadline');
        startEl.textContent = app.formatDate(item.Start_Date);
        deadlineEl.textContent = app.formatDate(item.Deadline);

        // Calculate Days Left for Detail View
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        const deadline = new Date(item.Deadline);
        const diffTime = deadline - today;
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

        const urgencyEl = document.getElementById('detail-urgency');
        if (urgencyEl) {
            if (isNaN(diffDays)) {
                urgencyEl.textContent = `Deadline: ${item.Deadline}`;
            } else if (diffDays < 0) {
                urgencyEl.textContent = "Closed";
            } else if (diffDays === 0) {
                urgencyEl.textContent = "⏰ Ends Today";
            } else {
                urgencyEl.textContent = `⏰ ${diffDays} days left`;
            }
        }

        // Link
        const applyBtn = document.getElementById('detail-apply-btn');
        if (applyBtn) {
            applyBtn.href = item.Source_Link;
        }

        // Dynamic Important Notes
        const notesBox = document.getElementById('detail-notes-box');
        if (notesBox) {
            let noteText = "<strong>Important Note:</strong> ";
            if (diffDays < 0) {
                noteText += "This scholarship is currently closed. Keep checking back for the next cycle.";
            } else if (diffDays <= 7) {
                noteText += `Deadline is approaching very soon! Submit your application within the next ${diffDays} days to ensure consideration.`;
            } else {
                noteText += "Ensure all documents are scanned clearly and your profile is 100% complete before submission. Early applications are highly recommended.";
            }
            notesBox.innerHTML = `<p>${noteText}</p>`;
        }

        // Badges
        if (badgesContainer) {
            const statusClass = item.calculatedStatus.toLowerCase().replace(' ', '-');
            const typeClass = item.Type.toLowerCase();

            const statusBadge = document.createElement('span');
            statusBadge.className = `badge ${statusClass}`;
            statusBadge.textContent = item.calculatedStatus;

            const typeBadge = document.createElement('span');
            typeBadge.className = `badge ${typeClass}`;
            typeBadge.textContent = item.Type;

            badgesContainer.appendChild(statusBadge);
            badgesContainer.appendChild(typeBadge);
        }

        // Lists
        const createListItems = (arr, elementId) => {
            const el = document.getElementById(elementId);
            arr.forEach(txt => {
                const li = document.createElement('li');
                li.textContent = txt;
                el.appendChild(li);
            });
        };

        createListItems(item.Eligibility, 'detail-eligibility');
        createListItems(item.Documents_Required, 'detail-docs');

        // Update Bookmark Toggle in Detail
        const isBookmarked = app.state.bookmarks.includes(item.id);
        const bookmarkBtn = document.getElementById('detail-bookmark-btn');
        if (bookmarkBtn) {
            bookmarkBtn.className = `btn-bookmark ${isBookmarked ? 'active' : ''}`;
            bookmarkBtn.innerHTML = isBookmarked ? '🔖' : '🔖';
        }

        // Populate Tracking and Reminders
        const trackingPlaceholder = document.getElementById('detail-tracking-placeholder');
        const remindersPlaceholder = document.getElementById('detail-reminders-placeholder');

        if (trackingPlaceholder && remindersPlaceholder) {
            const trackingStatus = app.state.tracking[item.id] || 'none';

            trackingPlaceholder.innerHTML = `
                <div class="section tracking-controls">
                    <h3>📍 Set Status</h3>
                    <p style="font-size: 0.85rem;">Track your progress on this application.</p>
                    <div class="tracking-options">
                        <button class="btn-tracking ${trackingStatus === 'Planning' ? 'active' : ''}" onclick="app.updateTrackingStatus('${item.id}', 'Planning')">Planning</button>
                        <button class="btn-tracking ${trackingStatus === 'Applied' ? 'active' : ''}" onclick="app.updateTrackingStatus('${item.id}', 'Applied')">Applied</button>
                        <button class="btn-tracking ${trackingStatus === 'Missed' ? 'active' : ''}" onclick="app.updateTrackingStatus('${item.id}', 'Missed')">Missed</button>
                    </div>
                </div>
            `;

            // Share On section removed per user request
            remindersPlaceholder.innerHTML = '';
        }
    },

    // --- Results Filtering & Sorting ---

    handleResultsSearch: () => {
        app.applyResultsFiltersAndSort();
    },

    handleResultsFilterSort: () => {
        app.applyResultsFiltersAndSort();
    },

    clearResultsFilters: () => {
        const searchInput = document.getElementById('search-input');
        const sortDeadline = document.getElementById('sort-deadline');
        const sortAmount = document.getElementById('sort-amount');
        const openOnlyCheck = document.getElementById('filter-open-only');

        if (searchInput) searchInput.value = '';
        if (sortDeadline) sortDeadline.value = 'none';
        if (sortAmount) sortAmount.value = 'none';
        if (openOnlyCheck) openOnlyCheck.checked = false;

        app.applyResultsFiltersAndSort();
    },

    applyResultsFiltersAndSort: () => {
        // 1. Get base scholarships using stored user profile
        let results = window.DataService.getScholarships(app.state.userProfile);

        // 2. Secondary Keyword Filter
        const query = document.getElementById('search-input')?.value.toLowerCase().trim();
        if (query) {
            results = results.filter(s => {
                const nameMatch = s.Scholarship_Name.toLowerCase().includes(query);
                const overviewMatch = s.Overview.toLowerCase().includes(query);

                const normalizedAmount = s.Benefit_Amount ? s.Benefit_Amount.replace(/[^\d]/g, '') : "";
                const amountMatch = (s.Benefit_Amount && s.Benefit_Amount.toLowerCase().includes(query)) ||
                    (normalizedAmount && query.replace(/[^\d]/g, '') && normalizedAmount.includes(query.replace(/[^\d]/g, '')));

                return nameMatch || overviewMatch || amountMatch;
            });
        }

        // 3. Status Filter (Open Only)
        const openOnly = document.getElementById('filter-open-only')?.checked;
        if (openOnly) {
            results = results.filter(s => s.calculatedStatus === 'Open' || s.calculatedStatus === 'Closing Soon');
        }

        // 4. Dual Sorting logic
        const sortDeadline = document.getElementById('sort-deadline')?.value;
        const sortAmount = document.getElementById('sort-amount')?.value;

        results.sort((a, b) => {
            const getSortAmount = (str) => {
                if (!str) return 0;
                const s = str.toLowerCase();
                if (s.includes("full") || s.includes("funding")) return 99999999;
                const matches = str.replace(/[,₹]/g, '').match(/\d+/g);
                if (!matches) return 0;
                const numbers = matches.map(m => parseInt(m));
                return Math.max(...numbers);
            };

            if (sortDeadline && sortDeadline !== 'none') {
                const dateA = new Date(a.Deadline);
                const dateB = new Date(b.Deadline);
                const diff = sortDeadline === 'asc' ? dateA - dateB : dateB - dateA;
                if (diff !== 0) return diff;
            }

            if (sortAmount && sortAmount !== 'none') {
                const amtA = getSortAmount(a.Benefit_Amount);
                const amtB = getSortAmount(b.Benefit_Amount);
                return sortAmount === 'desc' ? amtB - amtA : amtA - amtB;
            }

            return 0;
        });

        const countEl = document.getElementById('results-count');
        if (countEl) {
            countEl.textContent = `${results.length} found`;
        }

        app.renderScholarshipList(results);
    },

    // --- Theme Control ---
    toggleDarkMode: () => {
        const isDark = document.body.classList.toggle('dark-mode');
        localStorage.setItem('theme', isDark ? 'dark' : 'light');
    },

    // --- Persistence ---

    loadUserData: () => {
        try {
            const data = localStorage.getItem('scholarship_data');
            if (data) {
                const parsed = JSON.parse(data);
                app.state.userProfile = parsed.userProfile || app.state.userProfile;
                app.state.bookmarks = parsed.bookmarks || [];
                app.state.tracking = parsed.tracking || {};
                app.state.recent = parsed.recent || [];
            }
        } catch (e) {
            console.error("Error loading user data", e);
        }
    },

    saveUserData: () => {
        const data = {
            userProfile: app.state.userProfile,
            bookmarks: app.state.bookmarks,
            tracking: app.state.tracking,
            recent: app.state.recent
        };
        localStorage.setItem('scholarship_data', JSON.stringify(data));

        const savedCount = document.getElementById('saved-count');
        if (savedCount) {
            const count = app.state.bookmarks.length;
            savedCount.textContent = count;
            savedCount.style.display = count > 0 ? 'inline-block' : 'none';
        }
    },

    // --- Feature Handlers ---

    toggleBookmark: (id, event) => {
        if (event) event.stopPropagation();

        const index = app.state.bookmarks.indexOf(id);
        if (index > -1) {
            app.state.bookmarks.splice(index, 1);
        } else {
            app.state.bookmarks.push(id);
        }

        app.saveUserData();

        if (window.isStaticPage) {
            // Dynamically update bookmark UI state for static page
            const isBookmarked = app.state.bookmarks.includes(id);
            const bookmarkBtn = document.getElementById('detail-bookmark-btn');
            if (bookmarkBtn) {
                bookmarkBtn.className = `btn-bookmark ${isBookmarked ? 'active' : ''}`;
                bookmarkBtn.innerHTML = '&#128278;';
            }
            
            // Also update any card bookmarks (e.g. Related Scholarships)
            const cardBtn = document.querySelector(`.scholarship-card[data-id="${id}"] .btn-bookmark`);
            if (cardBtn) {
                cardBtn.className = `btn-bookmark ${isBookmarked ? 'active' : ''}`;
            }
            return;
        }

        if (app.state.currentView === 'list') {
            app.applyResultsFiltersAndSort();
        } else if (app.state.currentView === 'detail') {
            app.renderScholarshipDetail(id);
        } else if (app.state.currentView === 'dashboard') {
            app.showDashboard();
        }
    },

    updateTrackingStatus: (id, status, event) => {
        if (event) event.stopPropagation();

        const currentStatus = app.state.tracking[id];
        if (currentStatus === status) {
            delete app.state.tracking[id];
        } else {
            if (status === 'none') {
                delete app.state.tracking[id];
            } else {
                app.state.tracking[id] = status;
            }
        }
        app.saveUserData();

        if (window.isStaticPage) {
            // Sync status selection buttons for static page
            const trackingStatus = app.state.tracking[id] || 'none';
            const trackingOptions = document.querySelectorAll('.tracking-options .btn-tracking');
            trackingOptions.forEach(btn => {
                if (btn.textContent.trim() === trackingStatus) {
                    btn.classList.add('active');
                } else {
                    btn.classList.remove('active');
                }
            });
            return;
        }

        if (app.state.currentView === 'detail') {
            app.renderScholarshipDetail(id);
        } else if (app.state.currentView === 'dashboard') {
            app.showDashboard();
        }
    },

    addToRecent: (id) => {
        app.state.recent = app.state.recent.filter(item => item !== id);
        app.state.recent.unshift(id);
        if (app.state.recent.length > 10) {
            app.state.recent.pop();
        }
        app.saveUserData();
    },

    shareScholarship: (id, type) => {
        const item = window.DataService.getById(id);
        if (!item) return;

        const deadline = app.formatDate(item.Deadline);
        const name = item.Scholarship_Name;
        const link = item.Source_Link;

        if (type === 'copy') {
            // Copy link to clipboard
            navigator.clipboard.writeText(link).then(() => {
                alert('✅ Link copied to clipboard!');
            }).catch(() => {
                // Fallback for older browsers
                const textArea = document.createElement('textarea');
                textArea.value = link;
                document.body.appendChild(textArea);
                textArea.select();
                document.execCommand('copy');
                document.body.removeChild(textArea);
                alert('✅ Link copied to clipboard!');
            });
        } else if (type === 'email') {
            const subject = encodeURIComponent(`Scholarship Opportunity: ${name}`);
            const body = encodeURIComponent(`🎓 Scholarship Opportunity\n\nScholarship: ${name}\n📅 Deadline: ${deadline}\n🔗 Official Link: ${link}\n\nShared via Scholar Slop`);
            window.location.href = `mailto:?subject=${subject}&body=${body}`;
        }
    },

    showDashboard: () => {
        app.state.currentView = 'dashboard';
        document.body.classList.remove('home-bg');
        app.renderView('view-dashboard');
        app.renderDashboardSections();
    },

    renderDashboardSections: () => {
        const savedResults = app.state.bookmarks.map(id => window.DataService.getById(id)).filter(Boolean);
        app.renderSmallList('dashboard-saved-list', savedResults, "You haven't saved any scholarships yet.", 'bookmark');

        const trackingIds = Object.keys(app.state.tracking);
        const trackingResults = trackingIds.map(id => ({
            ...window.DataService.getById(id),
            trackingStatus: app.state.tracking[id]
        })).filter(item => item.id);
        app.renderSmallList('dashboard-tracking-list', trackingResults, "No scholarships are currently being tracked.", 'tracking');

        const recentResults = app.state.recent.map(id => window.DataService.getById(id)).filter(Boolean);
        app.renderSmallList('dashboard-recent-list', recentResults, "No recently viewed scholarships.", 'recent');
    },

    renderSmallList: (containerId, items, emptyMsg, type) => {
        const container = document.getElementById(containerId);
        if (!container) return;

        if (items.length === 0) {
            container.innerHTML = `<p class="empty-state">${emptyMsg}</p>`;
            return;
        }

        container.innerHTML = '';
        items.forEach(item => {
            const card = document.createElement('div');
            card.className = 'mini-card';
            card.onclick = () => app.showDetail(item.id);

            const trackingBadge = item.trackingStatus ? `<span class="badge badge-status">${item.trackingStatus}</span>` : '';

            let actionBtn = '';
            if (type === 'bookmark') {
                actionBtn = `<button class="btn-mini-action" onclick="app.toggleBookmark('${item.id}', event)" title="Remove Bookmark">✕</button>`;
            } else if (type === 'tracking') {
                actionBtn = `<button class="btn-mini-action" onclick="app.updateTrackingStatus('${item.id}', 'none', event)" title="Stop Tracking">✕</button>`;
            }

            card.innerHTML = `
                <div class="mini-card-content">
                    <h4>${item.Scholarship_Name}</h4>
                    <p>Deadline: ${app.formatDate(item.Deadline)}</p>
                    ${trackingBadge}
                </div>
                ${actionBtn}
            `;
            container.appendChild(card);
        });
    },

    formatDate: (dateStr) => {
        if (!dateStr) return "N/A";
        const d = new Date(dateStr);
        if (isNaN(d.getTime())) {
            return dateStr;
        }
        const options = { year: 'numeric', month: 'short', day: 'numeric' };
        return d.toLocaleDateString('en-IN', options);
    },

    toggleFaq: (event) => {
        if (event) event.stopPropagation();
        const trigger = event.currentTarget;
        const item = trigger.closest('.faq-accordion-item');
        const content = item.querySelector('.faq-accordion-content');
        const icon = trigger.querySelector('.faq-icon');
        
        const isOpen = item.classList.toggle('open');
        if (isOpen) {
            content.style.maxHeight = content.scrollHeight + 'px';
            icon.innerHTML = '&#8722;'; // Minus
        } else {
            content.style.maxHeight = '0px';
            icon.innerHTML = '&#43;'; // Plus
        }
    },

    downloadDocumentsList: (event) => {
        if (event) event.stopPropagation();

        const scholarshipId = app.state.selectedScholarshipId;
        if (!scholarshipId) return;

        const item = window.DataService.getById(scholarshipId);
        if (!item) return;

        // Ensure jsPDF is loaded
        if (!window.jspdf) {
            alert("PDF generation library not loaded. Please refresh the page.");
            return;
        }

        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();

        // --- PDF Styling & Content ---

        // 1. Header
        doc.setFont("helvetica", "bold");
        doc.setFontSize(18);
        doc.setTextColor(33, 150, 243); // Blue Theme Color
        doc.text("DOCUMENTS REQUIRED CHECKLIST", 20, 20);

        // 2. Scholarship Details
        doc.setFont("helvetica", "normal");
        doc.setFontSize(12);
        doc.setTextColor(0, 0, 0);

        // Wrap long scholarship names
        const titleLines = doc.splitTextToSize(`Scholarship: ${item.Scholarship_Name}`, 170);
        doc.text(titleLines, 20, 35);

        let currentY = 35 + (titleLines.length * 7);

        doc.text(`State: ${item.State}`, 20, currentY);
        currentY += 7;
        doc.text(`Category: ${item.Category}`, 20, currentY);
        currentY += 7;
        doc.text(`Application Deadline: ${app.formatDate(item.Deadline)}`, 20, currentY);
        currentY += 15;

        // Separator Line
        doc.setLineWidth(0.5);
        doc.line(20, currentY, 190, currentY);
        currentY += 15;

        // 3. Checklist
        doc.setFont("helvetica", "bold");
        doc.setFontSize(14);
        doc.text("Required Documents:", 20, currentY);
        currentY += 10;

        doc.setFont("helvetica", "normal");
        doc.setFontSize(12);

        item.Documents_Required.forEach((docItem, index) => {
            // Draw checkbox square
            doc.rect(20, currentY - 4, 5, 5);

            // Document Name
            doc.text(docItem, 30, currentY);
            currentY += 10;
        });

        currentY += 10;

        // 4. Important Notes
        doc.setFont("helvetica", "bold");
        doc.setFontSize(11);
        doc.setTextColor(100, 100, 100); // Gray
        doc.text("IMPORTANT NOTES:", 20, currentY);
        currentY += 7;

        doc.setFont("helvetica", "italic");
        doc.setFontSize(10);
        const notes = [
            "• Ensure all documents are scanned clearly.",
            "• File formats: PDF/JPG preferred (check official portal).",
            "• Verify document validity before uploading.",
            "• Keep original copies ready for verification."
        ];

        notes.forEach(note => {
            doc.text(note, 20, currentY);
            currentY += 6;
        });

        // 5. Footer
        const pageHeight = doc.internal.pageSize.height;
        doc.setFontSize(9);
        doc.setTextColor(150, 150, 150);

        doc.text(`Generated on: ${new Date().toLocaleString('en-IN')}`, 20, pageHeight - 20);
        doc.text("Source: Scholar Slop", 20, pageHeight - 15);

        // Add Application Link (Clickable)
        doc.setTextColor(33, 150, 243);
        doc.textWithLink("Apply Now: " + item.Source_Link, 20, pageHeight - 10, { url: item.Source_Link });

        // Create a safe filename
        const safeFileName = item.Scholarship_Name
            .replace(/[^a-z0-9]/gi, '_')
            .toLowerCase()
            .substring(0, 50);

        doc.save(`${safeFileName}_checklist.pdf`);
    }
};

document.addEventListener('DOMContentLoaded', app.init);
window.app = app;
