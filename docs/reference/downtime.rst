Downtime Protocol
=================

"Downtime" is interpreted from the perspective of the user: if they cannot use the service as they normally would, then it’s some degree of "down."

If a service is expected or discovered to be unresponsive, then the following protocol should be followed.

Setting expectations
--------------------

OCP has a maintenance contract with Dogsbody Technology, which includes:

-  Actively monitoring services.
-  Reacting to downtime within 30 minutes (during working hours).
-  Spending an initial 20 minutes triaging the issue.

Working hours are 9:00-17:00 UK time, Monday-Friday, excluding UK public holidays.

Notification mechanisms
-----------------------

Notifications should be sent to sysadmin@open-contracting.org, to coordinate with and notify other users that maintain servers. Subscribers include members of OCP and Dogsbody Technology.

For urgent decisions requiring OCP approval (notably, new expenditures relating to provisioning or upgrading servers), communicate via Slack or email and, if needed, send a 'ping' via WhatsApp or SMS to James McKinney (`EST/EDT <https://www.timeanddate.com/time/zones/est>`__) or, if no response, Lindsey Marchessault (`MST/MDT <https://www.timeanddate.com/time/zones/mst>`__).

Protocol
--------

Planned downtime / disruption
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If changes might disrupt a service, a notification should be sent 72h (or at minimum 24h) before the changes occur, which should include: a description of the disruption, its timing, any actions that users might need to take, and details of the priority/urgency of the work. Further notifications should be made, in line with the protocol for unplanned downtime.

What counts as "disruptive" depends on the service. Example: If changes to Kingfisher Collect would require crawls to restart, it is disruptive only if there are running crawls that analysts wouldn’t want to restart. If unsure, please discuss with James McKinney.

Mitigations should be put in place if possible and proportionate to the disruption. Example: If the Data Review Tool needs to be offline for an hour, we can use a maintenance page to inform users of the maintenance window, without sending any notifications.

Downtime < 30 minutes per incident, or < 3 incidents in 24h
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If the service is online, then a cursory inspection of the state of the service should be made, and if the cause cannot be easily found, then a GitHub issue can be created for the later investigation of the cause of the downtime.

Remedial action should be taken if possible, and a GitHub issue can be created for any follow-up that is required. Any suggestions for changes to improve long-term reliability should be added to the relevant work stream as for any other item of work.

Any identified key users should be notified if there is likely to be ongoing disruption to their work, or if they have mentioned the downtime.

Downtime > 30 minutes per incident, or > 3 incidents in 24h
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If the service is offline, and has been for over 30 minutes, then a notification should be sent, to notify stakeholders of the downtime within 30 minutes of discovery. It should:

-  Communicate whether or not the downtime is being investigated. This allows others who may be able to help to either know to just wait, or how to contribute if they can. It also allows users to form realistic expectations. If the answer is that a service may be down for a protracted period, then users can adapt to that.
-  Outline the investigation so far: facts, feelings, any ideas of what might be done to solve the problem, and anticipated timescales.

During investigation, a notification should be sent at least every 4 hours to update users, unless something is happening that has a known duration longer than 4 hours, and that has been communicated to the mailing list. For example, if a backup is being run that will take 6 hours, a notification at the start and end of the backup is appropriate. Or, if it’s the end of the working day and the people investigating are leaving the issue overnight or over the weekend, a notification to that effect is appropriate, along with their anticipated return.

When the service is back up
~~~~~~~~~~~~~~~~~~~~~~~~~~~

When the service returns, a notification should be sent, along with any caveats.

Any follow-up actions or identified changes to improve long-term reliability should be added to a GitHub issue.

It might be appropriate to convene a retrospective to discuss the impact of the incident and mitigations that might be relevant.

Reference
---------

-  https://guides.18f.gov/engineering/our-approach/incident-reports/
