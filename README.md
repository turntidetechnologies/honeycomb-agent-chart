# Honeycomb Agent Helm Chart

This chart can let you install the [Honeycomb](https://honeycomb.io/)
[agent for Kubernetes][honeycomb-k8s-agent] using
[helm](https://helm.sh/).  It is based on the [generic kubernetes
quickstart resources][honeycomb-k8s-agent-quickstart].

To install it, create a Honeycomb account if you haven't already,
create a "kubernetes" integration called "kubernetes", and put the
team "write key" in a helm "values" file;

```yaml
honeycomb:
  writekey: 5fd8911af476985580a8fe70e04892c1
```

Also, if your kubernetes version is 1.13 or earlier, you will need to
configure it before you start.  Add `--set
honeycomb.legacyLogPaths=true` to the command lines, or a values file
of your choice.

Then you can install the chart using `helm`; for instance:

    helm install -f writekey.yaml --namespace honeycomb -n honeycomb-agent honeycomb-agent

That should get you started!  To debug, inspect the resources under
the `honeycomb` namespace.

See the [values file](honeycomb-agent/values.yaml) for more
information on configuration.

## Adding extra log monitoring

You might notice that it only imports logs from the kubernetes system
containers.

To add additional components for logging, create more values YAML
files, and pass them to the `helm` command with additional `-f`
arguments.  For example:

```yaml
honeycomb:
  watchers:
    staging:
      - namespace: staging
        selector:
          component: webservice
        parser: json
        processors:
          - &clog_time
            timefield:
              field: ts
              format: "2006-01-02T15:04:05.999999999Z07:00"
          - additional_fields:
              component: webservice
      - namespace: staging
        selector:
          component: microservice
        parser: json
        processors:
          - *clog_time
          - additional_fields:
              component: microservice
```

This configuration parses the output of two services, `webservice` and
`microservice`, which are presumed to be logging JSON with an RFC3339
format timestamp including a nanosecond component with the key `ts`.
For more details on the configuration format, see [the agent
configuration description][agent-configuration].  It sends them to the
`staging` dataset (see below).

One key change to allow composition of values files is that the
`watchers` value is a mapping, not a list.  This is because helm
replaces a list with a new list when merging the values files.  Using
a mapping allows merging to happen, as long as you do not re-use keys.
It also defaults `dataset` to these keys; you can override as you see
fit.  See the [dataset best practices][dataset-best-practices] for
guidelines on how to split your datasets.

This chart also allows the label selector to be passed as a mapping as
key `selector`, and it builds the `labelSelector` field by converting
the keys and values into a `key=value` list.  If you pass
`labelSelector` directly, the `selector` field is ignored.

## A note on log drivers

The Honeycomb kubernetes agent only works if your kubernetes cluster
is using the Docker runtime with the `json-file` log driver.  For
instance, if you set up on a system which uses `systemd` then you
might have your logs going to `systemd-journald` instead.  If you see
lots of "no such file or directory" errors in the `honeycomb-agent`
pods, this is probably what is happening.

Unless you particularly care which log driver you are using, you may
as well switch to `json-file`.

Alternate container runtimes probably also won't work if they use a
different filesystem layout for container logs.

If you run into either of these problems, are handy with Go and have
the time, try enhancing honeycomb kubernetes agent (take a look at
[this function][determineLogPattern],
for example) and sending a Pull Request to Honeycomb.  They also have
a premium support option.

[honeycomb-k8s-agent]: https://docs.honeycomb.io/getting-data-in/integrations/kubernetes/
[determineLogPattern]: https://github.com/honeycombio/honeycomb-kubernetes-agent/blob/201433f111ec16c31a3316308707513de8bf6d53/podtailer/podtailer.go#L161
[agent-configuration]: https://github.com/honeycombio/honeycomb-kubernetes-agent#production-ready-use
[dataset-best-practices]: https://docs.honeycomb.io/getting-data-in/best-practices/
[honeycomb-k8s-agent-quickstart]: https://honeycomb.io/download/kubernetes/logs/quickstart.yaml

## Author and License

Initial version written by Sam Vilain.

Copyright (c) 2019, Software Motor Company.

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
