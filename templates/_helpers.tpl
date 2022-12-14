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

{{- define "configmap.fullname" }}
{{- printf "%s-%s-cm" .Values.global.prefix .Values.namespace.name }}
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
- containerPort: {{ .number }}
  name: {{ printf "svc-%d" (int .number) }}
  protocol: TCP
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "main.service.port.range" }}
{{- if ge (len .Values.main.service.ports) 0 }}
ports:
{{- range .Values.main.service.ports }}
{{- if eq .type "http" }}
- port: {{ .number }}
  targetPort: {{ .number }}
  name: {{ printf "%s-%d" .type (int .number) }}
  protocol: TCP
{{- else }}
- port: {{ .number }}
  targetPort: {{ .number }}
  name: {{ printf "%s" .type }}
  protocol: TCP
{{- end -}}
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

{{- define "main.ingress.istio.matchers" }}
{{- if ge (len .Values.main.ingress.paths) 1 }}
{{- range .Values.main.ingress.paths }}
- uri:
    prefix: {{ . }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "main.ingress.contour.matchers" }}
{{- if ge (len .Values.main.ingress.paths) 1 }}
{{- $fullname := include "main.service.fullname" . }}
{{- $ingressPort := .Values.main.ingress.port }}
{{- range .Values.main.ingress.paths }}
- pathType: Prefix
  path: {{ . }}
  backend:
    service:
      name: {{ $fullname }}
      port:
        number: {{ $ingressPort }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "main.ingress.contour.grpc" }}
{{- $backendService := include "main.service.fullname" . }}
- backend:
    service:
      name: {{ $backendService }}
      port:
        number: {{ .Values.main.ingress.grpc.backend.port }}
  pathType: Prefix
  path: "/"
{{- end -}}
