/**
 * Shared API types used by both server routes and (optionally) generated iOS models.
 * Keep this file in sync with shared/openapi/openapi.yaml.
 */

export interface ExampleItem {
  id: string;
  title: string;
  createdAt: string;
}

export interface ExampleListResponse {
  data: ExampleItem[];
  total: number;
}

export interface HealthResponse {
  status: "ok" | "error";
  timestamp: string;
}
