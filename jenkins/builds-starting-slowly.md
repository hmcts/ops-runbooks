# Troubleshooting builds starting slowly

There are two main reasons for builds starting slowly.

One is contention for the `Queue` lock.

The other is multi branch events not being processed in a timely manner.

## Symptoms of the queue lock contention

- Builds not starting when 'Build now' is pressed
- Builds not starting when actions are done in GitHub like 'push' or creating a pull request.

More information can be found on the [CloudBees support article](https://support.cloudbees.com/hc/en-us/articles/360016134572-Jenkins-Jobs-are-not-Starting).

Generally this will involve taking thread dumps with [collectPerformanceData.sh](https://support.cloudbees.com/hc/en-us/articles/360016440131-What-is-collectPerformanceData-sh-and-how-does-it-help-) and then analysing them in something like [jstack.review](https://jstack.review/).

To use it you will need to find the PID of the Jenkins controller which can be done by running `jps`

Run `./collectPerformanceData.sh` to see what options you have.

Normally it's run with something like:
```command
./collectPerformanceData.sh  6 120 10
```

You can copy the tarball to your machine with:

(Replacing the pid if required, it's 6 in the example)

```command
kubectl cp -c jenkins jenkins-0:/var/jenkins_home/performanceData.6.output.tar.gz performanceData.6.output.tar.gz
```

Given we have no support contract for Jenkins you will likely need to either pin to the last working version (this can make upgrades very difficult so try avoid it) and report an issue on the plugin's issue tracker or create a fix ourselves (recommended).


## Multi branch events not being processed in a timely manner

There are two likely causes for this.

1. Events aren't actually arriving or are coming slowly because of a problem on the GitHub side
2. Jenkins can't process the queue quick enough

CFT Jenkins publishes metrics about the event queue to dynatrace.

You can see the events queue size on the [CFT Jenkins dashboard](https://ebe20728.live.dynatrace.com/#dashboard;id=4a6a6184-f1b6-486f-b810-3b93ef05e5b2;gf=all;gtf=-2h).

![SCM Event queue](./scm-event-queue.png)

As long as it's under 50 or so it's fine. During previous issues it was up to 1500+ which caused multi hour delays to builds starting.

There are additional metrics that you can look at like `pending` and `running`.

These can be checked in the Dynatrace metrics explorer, search `jenkins.scm.event`.

If Dynatrace isn't working or you're using SDS which doesn't currently have Dynatrace you can get the metrics directly at the current point in time by running the below script in the [Jenkins script console](https://www.jenkins.io/doc/book/managing/script-console/)


```command
jenkins.scm.api.SCMEvent.executorService
```

You should see something like:

> Result: java.util.concurrent.ScheduledThreadPoolExecutor@8b0291b[Running, pool size = 10, active threads = 10, queued tasks = 84, completed tasks = 21888]

Logs can be found in `/var/jenkins_home/logs/jenkins.branch.*`.

They aren't terribly useful, [@timja](https://github.com/timja) enhanced the logging in https://github.com/jenkinsci/branch-api-plugin/pull/305 but we didn't end up investing time to try get it merged as it served its purpose but could be revived again if ever needed.

## References

- [My Jenkins build isn't triggering when I push](https://blog.timja.dev/my-jenkins-build-isnt-triggering-when-i-push/) - Post by [@timja](https://github.com/timja) on a previous issue we had with builds not triggering