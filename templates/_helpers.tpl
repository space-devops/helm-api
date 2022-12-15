{{- define "deployment.fullname" }}
{{- printf "api-%s-deploy" .Values.namespace.name }}
{{- end }}

{{- define "main.pod.fullname" }}
{{- printf "main-pod-%s" .Values.namespace.name }}
{{- end }}

{{- define "main.container.fullname" }}
{{- printf "main-container-%s" .Values.namespace.name }}
{{- end }}

{{- define "init.container.fullname" }}
{{- printf "init-%s-imposters" .Values.namespace.name }}
{{- end }}

{{- define "main.container.image" }}
{{- printf "%s:%s" .Values.main.deployment.image.name .Values.main.deployment.image.version -}}
{{- end }}

{{- define "init.container.image" }}
{{- printf "%s:%s" .Values.init.deployment.image.name .Values.init.deployment.image.version -}}
{{- end }}

{{- define "main.service.fullname" }}
{{- printf "main-svc-%s" .Values.namespace.name }}
{{- end }}

{{- define "main.container.security.context" }}
securityContext:
  runAsUser: {{ .Values.main.security.context.userId }}
  {{- if .Values.main.security.context.isRoot -}}
  runAsNonRoot: false
  {{- else }}
  runAsNonRoot: true
  {{- end }}
  privileged: {{ .Values.main.security.context.isPrivileged }}
{{- end }}

{{- define "init.container.security.context" }}
securityContext:
  runAsUser: {{ .Values.init.security.context.userId }}
  {{- if .Values.init.security.context.isRoot -}}
  runAsNonRoot: false
  {{- else }}
  runAsNonRoot: true
  {{- end }}
  privileged: {{ .Values.init.security.context.isPrivileged }}
{{- end }}

{{- define "main.container.port.range" }}
{{- if ge (len .Values.main.service.ports) 0 }}
ports:
{{- range .Values.main.service.ports }}
- containerPort: {{ . }}
  name: {{ printf "svc-%d" (int .) }}
  protocol: TCP
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "main.service.port.range" }}
{{- if ge (len .Values.main.service.ports) 0 }}
ports:
{{- range .Values.main.service.ports }}
- port: {{ . }}
  targetPort: {{ . }}
  name: {{ printf "svc-%d" (int .) }}
  protocol: TCP
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "main.container.readiness" }}
readinessProbe:
  httpGet:
    port: {{ .Values.main.service.healthCheck.readiness.port }}
    path: {{ .Values.main.service.healthCheck.readiness.path }}
  initialDelaySeconds: {{ .Values.main.service.healthCheck.readiness.delay }}
  periodSeconds: {{.Values.main.service.healthCheck.readiness.period }}
{{- end -}}

{{- define "main.container.liveness" }}
livenessProbe:
  httpGet:
    port: {{ .Values.main.service.healthCheck.liveness.port }}
    path: {{ .Values.main.service.healthCheck.liveness.path }}
  initialDelaySeconds: {{ .Values.main.service.healthCheck.liveness.delay }}
  periodSeconds: {{ .Values.main.service.healthCheck.liveness.period }}
  failureThreshold: {{ .Values.main.service.healthCheck.liveness.failures }}
{{- end -}}

{{- define "main.container.resources" }}
resources:
  requests:
    cpu: {{ .Values.main.deployment.resources.request.cpu }}
    memory: {{ .Values.main.deployment.resources.request.memory }}
  limits:
    cpu: {{ .Values.main.deployment.resources.limits.cpu }}
    memory: {{ .Values.main.deployment.resources.limits.memory }}
{{- end -}}

{{- define "init.container.resources" }}
resources:
  requests:
    cpu: {{ .Values.init.deployment.resources.request.cpu }}
    memory: {{ .Values.init.deployment.resources.request.memory }}
  limits:
    cpu: {{ .Values.init.deployment.resources.limits.cpu }}
    memory: {{ .Values.init.deployment.resources.limits.memory }}
{{- end -}}

{{- define "main.ingress.matchers" }}
{{- if ge (len .Values.main.ingress.paths) 1 }}
{{- range .Values.main.ingress.paths }}
- uri:
    prefix: {{ . }}
{{- end -}}
{{- end -}}
{{- end -}}