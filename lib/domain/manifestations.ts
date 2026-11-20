export const manifestationKinds = ["complaint", "report", "suggestion", "compliment", "request"] as const;
export type ManifestationKind = (typeof manifestationKinds)[number];
export const manifestationStatuses = ["received", "triage", "in_progress", "awaiting_information", "answered", "closed"] as const;
export type ManifestationStatus = (typeof manifestationStatuses)[number];
export type InstitutionRole = "owner" | "admin" | "ombudsman" | "analyst" | "viewer";
export const kindLabels: Record<ManifestationKind,string> = {
 complaint: "Reclamação", report: "Denúncia", suggestion: "Sugestão", compliment: "Elogio", request: "Solicitação"
};
export const statusLabels: Record<ManifestationStatus,string> = {
 received: "Recebida", triage: "Em triagem", in_progress: "Em andamento",
 awaiting_information: "Aguardando informações", answered: "Respondida", closed: "Concluída"
};
export const permittedTransitions: Record<ManifestationStatus,readonly ManifestationStatus[]> = {
 received: ["triage"], triage: ["in_progress","awaiting_information"],
 in_progress: ["awaiting_information","answered"], awaiting_information: ["in_progress"],
 answered: ["closed","in_progress"], closed: []
};
export function canTransition(from: ManifestationStatus, to: ManifestationStatus): boolean {
 return permittedTransitions[from].includes(to);
}
export function isManifestationKind(value: string): value is ManifestationKind {
 return (manifestationKinds as readonly string[]).includes(value);
}
