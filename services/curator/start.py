#!/usr/bin/env python3

import logging
import signal
import sys
import os

from periodtask import Task, TaskList, RUN
from periodtask.mailsender import MailSender

logging.basicConfig(format='%(message)s', level=logging.INFO)

if os.environ.get('CURATOR_SERVICE') != 'True':
    sys.exit(0)

send = MailSender(
    os.environ.get('EMAIL_HOST'),
    int(os.environ.get('EMAIL_PORT')),
    os.environ.get('EMAIL_FROM'),
    os.environ.get('EMAIL_RECIPIENT'),
    timeout=10,
    use_ssl=False,
    use_tls=False,
    username=None,
    password=None
).send_mail


tasks = TaskList(
    Task(
        name='Curator Service Backup Service',
        command=('./services/curator/curator.sh',),
        periods=os.environ.get(
            'CURATOR_CRON', '0 55 17 * * * Europe/Budapest'
        ),
        mail_skipped=send,
        mail_failure=send,
        run_on_start=os.environ.get('DEBUG') == 'True',
        wait_timeout=5,
        send_mail_func=send,
        stop_signal=signal.SIGTERM,
        policy=RUN
    )
)

tasks.start()
