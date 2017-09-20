# JUNOS-PR1247900-Detection

This bunch of scripts will scan through the routing table for blackhole routes, tested on raspbian, raspberry pi 1
- language used - expect and bash
- objective to detect RSVP-LSP routing blackholes and measure the duration of impact.
- work schematic
i.e

Cron triggers -> monitoring-loop.sh jump login to devices 
-> find_push script match rsvp lsp blachole signatures and stamp status.
 |- send_email.sh will send email to recipent if status permits
 |- send_sms.sh will send sms if status permits
 |- mark status to "dirty" for checking-recoveryloop.sh
                                                             
Cron triggers -> checking-recoveryloop.sh jump login to devices 
-> check status for "dirty" and update status when rsvp lsp recovers.
 |- send_email.sh will send email to recipent if status changes
 |- neutralized "dirty"                                                            

e.g. cron schedules

# Odd minute detect issue(s)
1-59/2 * * * * (cd /tmp/ongth && /bin/bash /tmp/ongth/monitoring-loop.sh router1.fqdn >/dev/null 2>&1)
1-59/2 * * * * (cd /tmp/ongth && /bin/bash /tmp/ongth/monitoring-loop.sh router2.fqdn >/dev/null 2>&1)
1-59/2 * * * * (cd /tmp/ongth && /bin/bash /tmp/ongth/monitoring-loop.sh router3.fqdn >/dev/null 2>&1)
1-59/2 * * * * (cd /tmp/ongth && /bin/bash /tmp/ongth/monitoring-loop.sh router4.fqdn >/dev/null 2>&1)

# Even minute measure and normalize issue(s)
*/2 * * * * (cd /tmp/ongth && /bin/bash /tmp/ongth/checking-recoveryloop.sh router1.fqdn >/dev/null 2>&1)
*/2 * * * * (cd /tmp/ongth && /bin/bash /tmp/ongth/checking-recoveryloop.sh router2.fqdn >/dev/null 2>&1)
*/2 * * * * (cd /tmp/ongth && /bin/bash /tmp/ongth/checking-recoveryloop.sh router3.fqdn >/dev/null 2>&1)
*/2 * * * * (cd /tmp/ongth && /bin/bash /tmp/ongth/checking-recoveryloop.sh router4.fqdn >/dev/null 2>&1)


