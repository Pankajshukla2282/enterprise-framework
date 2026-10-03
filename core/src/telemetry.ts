import { NodeSDK } from '@opentelemetry/sdk-node';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-http';
import { getNodeAutoInstrumentations } from '@opentelemetry/auto-instrumentations-node';
import { Resource } from '@opentelemetry/resources';
import { SemanticResourceAttributes } from '@opentelemetry/semantic-conventions';

let sdk: NodeSDK | undefined;

export function startTelemetry(serviceName: string) {
  if (sdk || process.env.OTEL_ENABLED === 'false') return;

  const endpoint = process.env.OTEL_EXPORTER_OTLP_ENDPOINT;
  const resource = new Resource({
    [SemanticResourceAttributes.SERVICE_NAME]: serviceName,
    [SemanticResourceAttributes.SERVICE_VERSION]: process.env.SERVICE_VERSION || '1.11.3',
    environment: process.env.NODE_ENV || 'development'
  });

  sdk = new NodeSDK({
    resource,
    traceExporter: endpoint ? new OTLPTraceExporter({ url: endpoint }) : undefined,
    instrumentations: [getNodeAutoInstrumentations()]
  });

  sdk.start();

  const shutdown = async () => {
    try {
      await sdk?.shutdown();
    } catch (e) {
      console.error('Telemetry shutdown failed', e);
    }
  };

  process.once('SIGTERM', shutdown);
  process.once('SIGINT', shutdown);
}
