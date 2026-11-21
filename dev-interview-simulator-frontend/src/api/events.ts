import { apiBaseUrl } from './client';

const VISITOR_ID_KEY = 'visitor_id';
const VISITOR_CONTEXT_KEY = 'visitor_context';
const BATCH_SIZE = 10;
const FLUSH_DELAY_MS = 400;

export type AnalyticsEventName =
  | 'landing_viewed'
  | 'profile_selected'
  | 'config_mode_selected'
  | 'config_level_selected'
  | 'config_theme_toggled'
  | 'config_personalize_opened'
  | 'simulation_started'
  | 'question_viewed'
  | 'question_answered'
  | 'simulation_completed'
  | 'simulation_abandoned'
  | 'result_viewed'
  | 'guest_cta_viewed'
  | 'guest_cta_clicked'
  | 'auth_modal_opened'
  | 'auth_method_chosen'
  | 'signup_completed'
  | 'login_completed';

export interface AnalyticsEventProperties {
  simulationId?: number | null;
  mode?: string | null;
  difficulty?: string | null;
  questionIndex?: number | null;
  metadata?: Record<string, unknown> | null;
}

type DeviceType = 'mobile' | 'tablet' | 'desktop';

interface VisitorContext {
  referrer: string;
  utmSource: string | null;
  utmMedium: string | null;
  utmCampaign: string | null;
}

interface AnalyticsEvent {
  visitorId: string;
  eventName: AnalyticsEventName;
  simulationId: number | null;
  mode: string | null;
  difficulty: string | null;
  questionIndex: number | null;
  deviceType: DeviceType;
  viewportWidth: number;
  referrer: string;
  utmSource: string | null;
  utmMedium: string | null;
  utmCampaign: string | null;
  metadata: Record<string, unknown> | null;
}

const generateVisitorId = (): string => {
  if (typeof crypto !== 'undefined' && typeof crypto.randomUUID === 'function') {
    return crypto.randomUUID();
  }
  return `visitor-${Date.now()}-${Math.random().toString(36).slice(2, 12)}`;
};

const readVisitorId = (): string => {
  try {
    const stored = localStorage.getItem(VISITOR_ID_KEY);
    if (stored) {
      return stored;
    }
    const generated = generateVisitorId();
    localStorage.setItem(VISITOR_ID_KEY, generated);
    return generated;
  } catch (error) {
    console.error('Identifiant visiteur non persistant', error);
    return generateVisitorId();
  }
};

const isVisitorContext = (value: unknown): value is VisitorContext => {
  if (!value || typeof value !== 'object') {
    return false;
  }
  const context = value as Record<string, unknown>;
  return typeof context.referrer === 'string'
    && (context.utmSource === null || typeof context.utmSource === 'string')
    && (context.utmMedium === null || typeof context.utmMedium === 'string')
    && (context.utmCampaign === null || typeof context.utmCampaign === 'string');
};

const currentContext = (): VisitorContext => {
  let params: URLSearchParams;
  try {
    params = new URLSearchParams(window.location.search);
  } catch (error) {
    console.error('Paramètres de campagne illisibles', error);
    params = new URLSearchParams();
  }
  return {
    referrer: typeof document !== 'undefined' ? document.referrer : '',
    utmSource: params.get('utm_source'),
    utmMedium: params.get('utm_medium'),
    utmCampaign: params.get('utm_campaign'),
  };
};

const readVisitorContext = (): VisitorContext => {
  const fallback = currentContext();
  try {
    const stored = localStorage.getItem(VISITOR_CONTEXT_KEY);
    if (stored) {
      const parsed: unknown = JSON.parse(stored);
      if (isVisitorContext(parsed)) {
        return parsed;
      }
    }
    localStorage.setItem(VISITOR_CONTEXT_KEY, JSON.stringify(fallback));
  } catch (error) {
    console.error('Contexte visiteur non persistant', error);
  }
  return fallback;
};

const visitorId = readVisitorId();
const visitorContext = readVisitorContext();

let queue: AnalyticsEvent[] = [];
let flushTimer: number | null = null;

const deviceType = (): DeviceType => {
  const width = window.innerWidth;
  if (width < 768) {
    return 'mobile';
  }
  if (width < 1024) {
    return 'tablet';
  }
  return 'desktop';
};

const buildEvent = (
  eventName: AnalyticsEventName,
  properties: AnalyticsEventProperties
): AnalyticsEvent => ({
  visitorId,
  eventName,
  simulationId: properties.simulationId ?? null,
  mode: properties.mode ?? null,
  difficulty: properties.difficulty ?? null,
  questionIndex: properties.questionIndex ?? null,
  deviceType: deviceType(),
  viewportWidth: window.innerWidth,
  referrer: visitorContext.referrer,
  utmSource: visitorContext.utmSource,
  utmMedium: visitorContext.utmMedium,
  utmCampaign: visitorContext.utmCampaign,
  metadata: properties.metadata ?? null,
});

const sendBatch = (batch: AnalyticsEvent[]): void => {
  try {
    const token = localStorage.getItem('jwt_token');
    void fetch(`${apiBaseUrl}/events`, {
      method: 'POST',
      keepalive: true,
      headers: {
        'Content-Type': 'application/json',
        ...(token ? { Authorization: `Bearer ${token}` } : {}),
      },
      body: JSON.stringify(batch),
    }).catch((error) => {
      console.error('Envoi des événements analytics impossible', error);
    });
  } catch (error) {
    console.error('Envoi des événements analytics impossible', error);
  }
};

const flush = (): void => {
  if (flushTimer !== null) {
    window.clearTimeout(flushTimer);
    flushTimer = null;
  }
  while (queue.length > 0) {
    sendBatch(queue.splice(0, BATCH_SIZE));
  }
};

const scheduleFlush = (): void => {
  if (flushTimer !== null) {
    return;
  }
  flushTimer = window.setTimeout(() => {
    flushTimer = null;
    flush();
  }, FLUSH_DELAY_MS);
};

export const trackEvent = (
  eventName: AnalyticsEventName,
  properties: AnalyticsEventProperties = {}
): void => {
  queue.push(buildEvent(eventName, properties));
  if (queue.length >= BATCH_SIZE) {
    flush();
    return;
  }
  scheduleFlush();
};

if (typeof window !== 'undefined') {
  window.addEventListener('pagehide', flush);
  document.addEventListener('visibilitychange', () => {
    if (document.visibilityState === 'hidden') {
      flush();
    }
  });
}
