# Builds not triggering from web-hooks

Jenkins is configured to receive web-hook events from a GitHub organisation level webhook.

The webhook can be seen at https://github.com/organizations/hmcts/settings/hooks

The webhook is created by the GitHub plugin.

It fires events which are listened for in the GitHub branch source plugin.

GitHub branch source then fires SCM events.

Branch API plugin puts these in a [`ScheduledThreadPoolExecutor`](https://github.com/jenkinsci/scm-api-plugin/blob/d5adf5eb0e399047884ba0e7335e8ae30df509ba/src/main/java/jenkins/scm/api/SCMEvent.java#L215)

Which has 10 threads hardcoded.

If events go passed that, they will be queued.

You can see the queue status by running:

```
jenkins.scm.api.SCMEvent.executorService
```

In the script console: https://build.platform.hmcts.net/script

You should see something like:
```
Result: java.util.concurrent.ScheduledThreadPoolExecutor@8b0291b[Running, pool size = 10, active threads = 10, queued tasks = 84, completed tasks = 21888]
```

Logs can be found in a couple of places.

Before a project match is found they will be logged globally on the Jenkins file system in:
`/var/jenkins_home/logs/jenkins.branch.*`

There's log rotation done by Jenkins, it keeps the last 5 logs and rotates them after 33KB, which is not much at all, we generally have 15 minutes worth of logs.

Logs are also found on the `Organization Folder Events` and `Multibranch Pipeline Events` pages which are located on Org folders and pipelines respectively.

You can take a set of thread dumps with a script called `collectPerformanceData.sh` which is published by CloudBees. It's linked to on their [troubleshooting page](https://support.cloudbees.com/hc/en-us/articles/360016440131-What-is-collectPerformanceData-sh-and-how-does-it-help-).

You can also normally find it sitting in `/var/jenkins_home/collectPerformanceData.sh` of our controllers.

To use it you will need to find the PID of the Jenkins controller which can be done by running `jps`

Run `./collectPerformanceData.sh` to see what options you have.

Normally I run it with something like:
```
./collectPerformanceData.sh  6 120 10
```

You can copy the tarball to your machine with:

(Replacing the pid if required, it's 6 in the example)

```
kubectl cp -c jenkins jenkins-0:/var/jenkins_home/performanceData.6.output.tar.gz performanceData.6.output.tar.gz
```

Run:
```
tar -xzf performanceData.6.output.tar.gz
```

Go to https://jstack.review/ and upload a selection of the files in the threads folder (not too many as it might kill your browser).

The thread we are interested in is NamedThread so it should be pretty easy to find.
Search `SCMEvent`.