const nodemailer = require('nodemailer');

function createTransporter() {
  const host = process.env.SMTP_HOST;
  const port = Number(process.env.SMTP_PORT || 587);
  const user = process.env.SMTP_USER;
  const pass = process.env.SMTP_PASS;

  if (!host || !user || !pass) {
    return null;
  }

  return nodemailer.createTransport({
    host,
    port,
    secure: port === 465,
    auth: { user, pass },
  });
}

function buildReminderHtmlTemplate({ shopName, ownerName, planName, subject, message }) {
  return `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>${subject}</title>
</head>
<body style="margin:0;padding:0;background-color:#f1f5f9;font-family:Arial,Helvetica,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background-color:#f1f5f9;padding:24px 12px;">
    <tr>
      <td align="center">
        <table width="560" cellpadding="0" cellspacing="0" style="max-width:560px;width:100%;background:#ffffff;border-radius:16px;overflow:hidden;border:1px solid #e2e8f0;">
          <tr>
            <td style="background:linear-gradient(135deg,#0f172a 0%,#1e3a8a 100%);padding:28px 24px;text-align:center;">
              <div style="display:inline-block;background:#f97316;color:#ffffff;font-weight:bold;font-size:12px;padding:4px 12px;border-radius:20px;letter-spacing:1px;margin-bottom:10px;">
                NEXT PLANNERS POS
              </div>
              <h1 style="margin:0;color:#ffffff;font-size:22px;font-weight:700;">Subscription Payment Reminder</h1>
              <p style="margin:6px 0 0;color:#cbd5e1;font-size:13px;">${shopName}</p>
            </td>
          </tr>
          <tr>
            <td style="padding:24px;">
              <p style="margin:0 0 12px;color:#0f172a;font-size:15px;">Dear <strong>${ownerName}</strong>,</p>
              <div style="background:#fff7ed;border:1px solid #fed7aa;border-radius:12px;padding:16px;margin:16px 0;">
                <div style="font-size:12px;color:#c2410c;font-weight:bold;text-transform:uppercase;margin-bottom:6px;">
                  Plan: ${planName || 'Active Plan'}
                </div>
                <p style="margin:0;color:#334155;font-size:14px;line-height:1.6;">
                  ${message}
                </p>
              </div>
              <p style="margin:16px 0 0;color:#64748b;font-size:12px;line-height:1.5;">
                Please clear your subscription dues to ensure uninterrupted POS, inventory, and multi-branch access.
              </p>
            </td>
          </tr>
          <tr>
            <td style="background:#f8fafc;padding:16px 24px;text-align:center;border-top:1px solid #e2e8f0;">
              <p style="margin:0;color:#94a3b8;font-size:11px;">
                © ${new Date().getFullYear()} Next Planners Tech Solution (NPTS) • Automated Billing Notice
              </p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>`;
}

exports.sendPaymentReminderEmail = async ({ to, shopName, ownerName, planName, subject, message }) => {
  const transporter = createTransporter();
  if (!transporter) {
    return {
      sent: false,
      reason: 'SMTP_HOST / SMTP_USER / SMTP_PASS not configured in backend/.env',
    };
  }

  const from = process.env.SMTP_FROM || process.env.SMTP_USER;
  const html = buildReminderHtmlTemplate({ shopName, ownerName, planName, subject, message });

  await transporter.sendMail({
    from,
    to,
    subject,
    text: message,
    html,
  });

  return { sent: true };
};
