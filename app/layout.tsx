import type { Metadata } from "next";
import "./globals.css";
export const metadata: Metadata = { title: "Ouvidoria | Portal de Atendimento", description: "Portal demonstrativo do Sistema de Ouvidoria" };
export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="pt-BR"><body>{children}</body></html>;
}
