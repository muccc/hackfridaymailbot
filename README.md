# hackfridaymailbot
scrape the wiki for content and generate an invitation email for hackfridays

## Requirements
  * bash
  * working ```mail``` or ```sendmail``` command

## Deployment

### With cron
  * run the script as a weekly cron-job, e.g. ```0 12 * * WED \path\to\hackfridaymailbot.sh```

### With systemd timer
  * run the following commands
  ```
  sudo cp contrib/* /etc/systemd/system/
  ```
  * adjust user, group and Execpath in ```/etc/systemd/system/hackfridaymailbot.service```
  * enable and start timer
  ```
  sudo systemctl daemon-reload
  sudo systemctl enable hackfridaymailbot.timer
  sudo systemctl start hackfridaymailbot.timer
  ```
