$(document).ready(function () {
    console.log("Interactive API Tester Pro Loaded");

    const API_BASE_URL = "https://pushtaka.xapi.my.id";
    let currentState = {
        token: localStorage.getItem('tester_token') || '',
        email: localStorage.getItem('tester_email') || '',
        bookId: null,
        transactionId: null
    };

    const steps = [
        {
            id: 1,
            title: "Register (Fail) - Email Tak Valid",
            description: "Mencoba mendaftar dengan format email yang salah untuk mengetes validasi.",
            endpoint: "POST /auth/register",
            payload: { email: "email-salah", password: "123", name: "User" },
            action: async (data) => $.ajax({
                url: `${API_BASE_URL}/auth/register`,
                method: 'POST',
                contentType: 'application/json',
                data: JSON.stringify(data)
            }).catch(err => err.responseJSON || err)
        },
        {
            id: 2,
            title: "Register (Success)",
            description: "Mendaftar dengan data valid untuk membuat akun baru.",
            endpoint: "POST /auth/register",
            payload: {
                email: "tester_" + Math.floor(Math.random() * 10000) + "@xan.id",
                password: "Password123!",
                name: "Tester Professional"
            },
            action: async (data) => {
                currentState.email = data.email;
                localStorage.setItem('tester_email', data.email);
                return $.ajax({
                    url: `${API_BASE_URL}/auth/register`,
                    method: 'POST',
                    contentType: 'application/json',
                    data: JSON.stringify(data)
                });
            }
        },
        {
            id: 3,
            title: "OTP (Fail) - Kode Salah",
            description: "Mencoba verifikasi dengan kode OTP asal-asalan.",
            endpoint: "POST /auth/otp",
            payload: { email: "", otp: "999999" },
            action: async (data) => {
                data.email = currentState.email;
                return $.ajax({
                    url: `${API_BASE_URL}/auth/otp`,
                    method: 'POST',
                    contentType: 'application/json',
                    data: JSON.stringify(data)
                }).catch(err => err.responseJSON || err);
            }
        },
        {
            id: 4,
            title: "OTP (Success)",
            description: "Verifikasi akun menggunakan kode shortcut 123456.",
            endpoint: "POST /auth/otp",
            payload: { email: "", otp: "123456" },
            action: async (data) => {
                data.email = currentState.email;
                return $.ajax({
                    url: `${API_BASE_URL}/auth/otp`,
                    method: 'POST',
                    contentType: 'application/json',
                    data: JSON.stringify(data)
                });
            }
        },
        {
            id: 5,
            title: "Login (Fail) - Password Salah",
            description: "Mencoba login dengan password yang tidak sesuai.",
            endpoint: "POST /auth/login",
            payload: { email: "", password: "SalahPassword" },
            action: async (data) => {
                data.email = currentState.email;
                return $.ajax({
                    url: `${API_BASE_URL}/auth/login`,
                    method: 'POST',
                    contentType: 'application/json',
                    data: JSON.stringify(data)
                }).catch(err => err.responseJSON || err);
            }
        },
        {
            id: 6,
            title: "Login (Success)",
            description: "Mendapatkan token JWT dengan kredensial yang benar.",
            endpoint: "POST /auth/login",
            payload: { email: "", password: "Password123!" },
            action: async (data) => {
                data.email = currentState.email;
                const res = await $.ajax({
                    url: `${API_BASE_URL}/auth/login`,
                    method: 'POST',
                    contentType: 'application/json',
                    data: JSON.stringify(data)
                });
                if (res.data && res.data.token) {
                    currentState.token = res.data.token;
                    localStorage.setItem('tester_token', res.data.token);
                }
                return res;
            }
        },
        {
            id: 7,
            title: "Cek Profil Saya",
            description: "Memverifikasi identitas user menggunakan Bearer Token.",
            endpoint: "GET /auth/me",
            action: async () => $.ajax({
                url: `${API_BASE_URL}/auth/me`,
                method: 'GET',
                headers: { "Authorization": `Bearer ${currentState.token}` }
            })
        },
        {
            id: 8,
            title: "List Koleksi Buku",
            description: "Mengambil data buku yang tersedia untuk dipinjam.",
            endpoint: "GET /books",
            action: async () => {
                const res = await $.ajax({
                    url: `${API_BASE_URL}/books`,
                    method: 'GET'
                });
                if (res.data && res.data.length > 0) {
                    currentState.bookId = res.data[0].id;
                }
                return res;
            }
        },
        {
            id: 9,
            title: "Pinjam Buku",
            description: "Melakukan transaksi peminjaman buku secara otomatis.",
            endpoint: "POST /transactions/borrow/{book_id}",
            action: async () => {
                if (!currentState.bookId) throw new Error("Silakan jalankan step 'List Buku' dahulu.");
                return $.ajax({
                    url: `${API_BASE_URL}/transactions/borrow/${currentState.bookId}`,
                    method: 'POST',
                    headers: { "Authorization": `Bearer ${currentState.token}` }
                });
            }
        },
        {
            id: 10,
            title: "Kembalikan Buku",
            description: "Proses pengembalian buku yang telah dipinjam.",
            endpoint: "POST /transactions/return/{book_id}",
            action: async () => {
                if (!currentState.bookId) throw new Error("Silakan jalankan step 'Pinjam Buku' dahulu.");
                return $.ajax({
                    url: `${API_BASE_URL}/transactions/return/${currentState.bookId}`,
                    method: 'POST',
                    headers: { "Authorization": `Bearer ${currentState.token}` }
                });
            }
        },
        {
            id: 11,
            title: "Riwayat Pinjaman",
            description: "Mengecek riwayat transaksi terakhir user.",
            endpoint: "GET /transactions/history",
            action: async () => $.ajax({
                url: `${API_BASE_URL}/transactions/history`,
                method: 'GET',
                headers: { "Authorization": `Bearer ${currentState.token}` }
            })
        }
    ];

    let currentStepIndex = 0;
    let stepResults = {}; // Cache for persistent results

    function updateProgressUI() {
        const total = steps.length;
        const current = currentStepIndex + 1;
        const percent = Math.round((current / total) * 100);

        $('#progress-stats').text(`Step ${current} / ${total} (${percent}%)`);
        $('#progress-bar-fill').css('width', `${percent}%`);
    }

    function renderStep(index) {
        const step = steps[index];
        const $container = $('#step-container');

        const method = step.endpoint.split(' ')[0];
        const path = step.endpoint.split(' ')[1] || '';
        const cachedResult = stepResults[index];

        $container.html(`
            <div class="step-card active">
                <div class="step-header">
                    <div class="step-num">${step.id}</div>
                    <div class="step-info">
                        <h3>${step.title}</h3>
                        <p>${step.description}</p>
                    </div>
                </div>
                <div class="step-body-split">
                    <!-- Left: Request -->
                    <div class="step-col-request">
                        <div class="step-col-title">
                            <span>Request Details</span>
                            <span class="badge ${method.toLowerCase()}">${method}</span>
                        </div>
                        <div class="endpoint-line">
                            <code>${path}</code>
                        </div>
                        ${step.payload ? `
                            <div class="payload-box">
                                <label style="font-size:0.8rem; color:var(--text-muted);">Payload Body:</label>
                                <textarea id="payload-input" style="height:200px;">${JSON.stringify(step.payload, null, 2)}</textarea>
                            </div>
                        ` : '<div style="padding:1rem; color:var(--text-muted); font-size:0.85rem; background:#f8fafc; border-radius:10px; border:1px dashed var(--border-color);">No payload for this request.</div>'}
                        
                        <div class="action-bar" style="margin-top:2rem;">
                            <button id="run-step" class="cta-button">Kirim Request</button>
                            ${currentStepIndex > 0 ? '<button id="prev-step" class="cta-outline">Kembali</button>' : ''}
                        </div>
                    </div>

                    <!-- Right: Response -->
                    <div class="step-col-response">
                        <div class="step-col-title">
                            <span>Response</span>
                            <span id="response-status-badge"></span>
                        </div>
                        <div id="response-loader" style="display:none; padding:2rem; text-align:center;">
                            <div style="width:30px; height:30px; border:3px solid #e2e8f0; border-top-color:var(--primary); border-radius:50%; animation: spin 1s linear infinite; margin:0 auto;"></div>
                            <p style="font-size:0.8rem; color:var(--text-muted); margin-top:1rem;">Menunggu respons server...</p>
                        </div>
                        <div id="response-container" class="response-container" style="${cachedResult ? 'display:block;' : 'display:none;'} margin-top:0; border:none; padding:0;">
                            <pre style="max-height:400px; border: 1px solid #1e293b;"><code id="response-block">${cachedResult ? JSON.stringify(cachedResult.data, null, 2) : ''}</code></pre>
                            <div id="response-time" style="font-size:0.75rem; color:var(--text-muted); margin-top:0.5rem; text-align:right; font-family:'JetBrains Mono',monospace;">
                                ${cachedResult ? `Execution: ${cachedResult.duration}ms` : ''}
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        `);

        if (cachedResult) {
            const $statusBadge = $('#response-status-badge');
            const response = cachedResult.data;
            if (response.status === "error" || response.error || (response.code && response.code >= 400)) {
                $statusBadge.html(`<span class="badge error" style="margin:0;">FAIL</span>`);
            } else {
                $statusBadge.html(`<span class="badge success" style="margin:0;">OK</span>`);
            }
        }

        // Update indicators
        $('.step-item-vert').removeClass('active completed');
        $('.step-item-vert').each(function (i) {
            if (i < index) $(this).addClass('completed');
            if (i === index) $(this).addClass('active');
        });

        updateProgressUI();
    }

    async function sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    async function runStepLogic() {
        const step = steps[currentStepIndex];
        const $resContainer = $('#response-container');
        const $resBlock = $('#response-block');
        const $resLoader = $('#response-loader');
        const $runBtn = $('#run-step');
        const $timeDisplay = $('#response-time');
        const $statusBadge = $('#response-status-badge');

        if (!$runBtn.length) return false;

        $runBtn.prop('disabled', true).text('Memproses...');
        $resContainer.hide();
        $resLoader.show();
        $statusBadge.html('');

        const startTime = performance.now();

        try {
            let payload = null;
            if (step.payload && $('#payload-input').length) {
                payload = JSON.parse($('#payload-input').val());
            }

            const response = await step.action(payload);
            const endTime = performance.now();
            const duration = (endTime - startTime).toFixed(0);

            // Store in cache
            stepResults[currentStepIndex] = { data: response, duration: duration };

            $resLoader.hide();
            $resBlock.text(JSON.stringify(response, null, 2));
            $timeDisplay.text(`Execution: ${duration}ms`);

            // Set status badge based on existence of error / code
            if (response.status === "error" || response.error || (response.code && response.code >= 400)) {
                $statusBadge.html(`<span class="badge error" style="margin:0;">FAIL</span>`);
            } else {
                $statusBadge.html(`<span class="badge success" style="margin:0;">OK</span>`);
            }

            $resContainer.fadeIn();

            if (currentStepIndex < steps.length - 1) {
                $runBtn.text('Lanjut ke Step Berikutnya').prop('disabled', false).attr('id', 'next-step');
            } else {
                $runBtn.text('Selesai!').prop('disabled', true);
            }
            return true;
        } catch (err) {
            const endTime = performance.now();
            const duration = (endTime - startTime).toFixed(0);
            const response = err.responseJSON || err;

            // Store in cache
            stepResults[currentStepIndex] = { data: response, duration: duration };

            console.error(err);
            $resLoader.hide();
            $resBlock.text(JSON.stringify(response, null, 2));
            $timeDisplay.text(`Execution: ${duration}ms`);
            $statusBadge.html(`<span class="badge error" style="margin:0;">ERROR</span>`);

            $resContainer.fadeIn();
            $runBtn.prop('disabled', false).text('Coba Lagi');
            return false;
        }
    }

    $(document).on('click', '.step-item-vert', function () {
        const index = $(this).data('step-index');
        currentStepIndex = index;
        renderStep(currentStepIndex);
    });

    $(document).on('click', '#run-step', async function () {
        await runStepLogic();
    });

    $(document).on('click', '#auto-run-btn', async function () {
        if (confirm("Mulai otomatis akan menjalankan semua skenario (Fail & Success) secara berurutan. Lanjutkan?")) {
            const $btn = $(this);
            $btn.prop('disabled', true).html('<span class="icon">⌛</span> Menjalankan...');
            $('#auto-run-log').show().text('Memulai skenario pengujian...');

            while (currentStepIndex < steps.length) {
                const step = steps[currentStepIndex];
                $('#auto-run-log').text(`[${currentStepIndex + 1}/${steps.length}] Menjalankan: ${step.title}...`);

                const success = await runStepLogic();
                // We continue even if success is false if it's an intentional fail test
                // but if it's a real connection error, we might want to stop.
                // For this UI, we just continue.

                await sleep(1500);
                if (currentStepIndex < steps.length - 1) {
                    currentStepIndex++;
                    renderStep(currentStepIndex);
                    await sleep(500);
                } else {
                    break;
                }
            }

            $('#auto-run-log').text('Seluruh skenario selesai dijalankan.');
            $btn.prop('disabled', false).html('<span class="icon">▶</span> Mulai Otomatis');
        }
    });

    $(document).on('click', '#reset-tester', function () {
        if (confirm("Reset semua progress dan mulai dari Step 1?")) {
            localStorage.removeItem('tester_token');
            localStorage.removeItem('tester_email');
            location.reload();
        }
    });

    $(document).on('click', '#next-step', function () {
        currentStepIndex++;
        renderStep(currentStepIndex);
    });

    $(document).on('click', '#prev-step', function () {
        currentStepIndex--;
        renderStep(currentStepIndex);
    });

    // Add spin animation
    $('head').append('<style>@keyframes spin { 100% { transform: rotate(360deg); } }</style>');

    // Initial render
    renderStep(currentStepIndex);
});
