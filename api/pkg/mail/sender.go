package mail

import (
	"crypto/tls"
	"fmt"

	"gopkg.in/gomail.v2"
)

type MailConfig struct {
	Host     string
	Port     int
	User     string
	Password string
}

type Sender interface {
	SendResetPassword(to string, token string) error
	SendOTP(to string, name string, otp string) error
}

type mailSender struct {
	dialer *gomail.Dialer
}

func NewMailSender(cfg MailConfig) Sender {
	dialer := gomail.NewDialer(cfg.Host, cfg.Port, cfg.User, cfg.Password)
	
	// Bypass verification for internal docker network or self-signed certs
	dialer.TLSConfig = &tls.Config{InsecureSkipVerify: true}

	return &mailSender{
		dialer: dialer,
	}
}

func (s *mailSender) SendResetPassword(to string, token string) error {
	m := gomail.NewMessage()
	m.SetAddressHeader("From", "noreply@pushtaka.xapi.my.id", "Pushtaka")
	m.SetHeader("To", to)
	m.SetHeader("Subject", "Reset Password - Pushtaka")
	
	htmlBody := fmt.Sprintf(`
		<h1>Reset Password</h1>
		<p>Anda meminta pengaturan ulang kata sandi.</p>
		<p>Gunakan token ini: <b>%s</b></p>
		<p>Atau gunakan token ini di API.</p>
	`, token)

	m.SetBody("text/html", htmlBody)

	if err := s.dialer.DialAndSend(m); err != nil {
		return fmt.Errorf("failed to send email: %v", err)
	}

	return nil
}

func (s *mailSender) SendOTP(to string, name string, otp string) error {
	m := gomail.NewMessage()
	m.SetAddressHeader("From", "noreply@pushtaka.xapi.my.id", "Pushtaka")
	m.SetAddressHeader("To", to, name)
	m.SetHeader("Subject", "Kode Verifikasi - Pushtaka")

	// Fallback name
	if name == "" {
		name = "User"
	}
	
	htmlBody := fmt.Sprintf(`
		<!DOCTYPE html>
		<html>
		<head>
			<style>
				body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; background-color: #f6f6f6; margin: 0; padding: 0; }
				.container { max-width: 600px; margin: 0 auto; padding: 20px; }
				.content { background-color: #ffffff; padding: 30px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
				.header { text-align: center; margin-bottom: 30px; }
				.logo { font-size: 24px; font-weight: bold; color: #333; text-decoration: none; }
				.otp-box { background-color: #f8f9fa; border: 1px solid #e9ecef; border-radius: 6px; padding: 20px; text-align: center; margin: 30px 0; }
				.otp-code { font-size: 32px; font-weight: bold; letter-spacing: 5px; color: #007bff; margin: 0; }
				.footer { text-align: center; margin-top: 30px; color: #999; font-size: 12px; }
				.warning { color: #dc3545; font-size: 14px; text-align: center; }
			</style>
		</head>
		<body>
			<div class="container">
				<div class="content">
					<div class="header">
						<span class="logo">PUSHTAKA</span>
					</div>
					<p>Halo <strong>%s</strong>,</p>
					<p>Anda meminta kode verifikasi untuk akun Pushtaka Anda. Silakan gunakan kode berikut untuk melanjutkan:</p>
					
					<div class="otp-box">
						<p class="otp-code">%s</p>
					</div>

					<p class="warning">Kode ini akan kadaluarsa dalam 5 menit.</p>
					<p>Jika Anda tidak meminta kode ini, Anda dapat mengabaikan email ini.</p>
				</div>
				<div class="footer">
					&copy; 2025 Pushtaka. Hak Cipta Dilindungi.
				</div>
			</div>
		</body>
		</html>
	`, name, otp)

	m.SetBody("text/html", htmlBody)

	if err := s.dialer.DialAndSend(m); err != nil {
		return fmt.Errorf("failed to send email: %v", err)
	}

	return nil
}
