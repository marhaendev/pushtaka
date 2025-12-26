$(document).ready(function () {
    console.log("Pushtaka Main JS Loaded");

    // Mobile Menu Toggle
    try {
        const $mobileBtn = $('.mobile-menu-btn');
        const $navLinks = $('.nav-links');
        if ($mobileBtn.length && $navLinks.length) {
            $mobileBtn.on('click', function () {
                $navLinks.toggleClass('active');
                $mobileBtn.toggleClass('active');
            });
        }
    } catch (e) { console.error("Mobile Menu Error:", e); }

    // ScrollSpy Implementation with Safety
    try {
        if ('IntersectionObserver' in window) {
            const observerOptions = {
                root: null,
                rootMargin: '-20% 0px -60% 0px',
                threshold: 0
            };

            const observer = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        const id = entry.target.getAttribute('id');
                        $('.sidebar-nav a').removeClass('active');
                        const $activeLink = $(`.sidebar-nav a[href="#${id}"]`);
                        if ($activeLink.length) {
                            $activeLink.addClass('active');
                            $activeLink[0].scrollIntoView({ behavior: 'smooth', block: 'nearest' });
                        }
                    }
                });
            }, observerOptions);

            const targets = [
                '#introduction', '#base-url',
                '#auth-register', '#auth-login', '#auth-profile', '#auth-otp',
                '#settings', '#users',
                '#book-list', '#book-detail', '#book-admin', '#favorites',
                '#borrow', '#return', '#history', '#transaction-admin'
            ];

            targets.forEach(selector => {
                const element = document.querySelector(selector);
                if (element) {
                    observer.observe(element);
                }
            });
        }
    } catch (e) { console.error("ScrollSpy Error:", e); }

    // Docs Tabs Logic - Simplified & Robust
    $(document).on('click', '.tab-btn', function () {
        const $btn = $(this);
        const $container = $btn.closest('.docs-tabs');
        const targetTab = $btn.attr('data-tab');

        if (!$container.length || !targetTab) return;

        // Toggle Buttons
        $container.find('> .tab-header .tab-btn').removeClass('active');
        $btn.addClass('active');

        // Toggle Content
        $container.find('> .tab-body > .tab-content').removeClass('active').hide();
        $container.find(`> .tab-body > .tab-content[data-content="${targetTab}"]`).addClass('active').fadeIn(200);
    });

    // Nested Status Tabs Logic
    $(document).on('click', '.status-tab-btn', function () {
        const $btn = $(this);
        const $container = $btn.closest('.status-tabs');
        const targetStatus = $btn.attr('data-status');

        if (!$container.length || !targetStatus) return;

        // Toggle Buttons
        $container.find('.status-tab-btn').removeClass('active');
        $btn.addClass('active');

        // Toggle Content
        $container.find('.status-tab-content').removeClass('active').hide();
        $container.find(`.status-tab-content[data-status-content="${targetStatus}"]`).addClass('active').show();
    });

    // Ensure initial state
    $('.tab-content').hide();
    $('.tab-content.active').show();
    $('.status-tab-content').hide();
    $('.status-tab-content.active').show();

    // Check for initial hash
    if (window.location.hash) {
        setTimeout(() => {
            const $target = $(window.location.hash);
            if ($target.length) {
                $target[0].scrollIntoView({ behavior: 'smooth' });
            }
        }, 300);
    }
});
