# DNT Volunteer Hub

Sistem de evidență și administrare organizațională pentru Direcția Națională a Tinerilor.

> „Every Volunteer. Every Branch. One Organization.”

## Fișiere
- `index.html` – aplicația (un singur fișier, logoul este inclus, nu necesită build).
- `schema.sql` – baza de date Supabase: tabele, funcții, trigger și politici RLS.

## Configurare
1. Creează un proiect NOU pe supabase.com și rulează `schema.sql` în SQL Editor (creează toate tabelele, RLS, audit automat, bucket-uri de fișiere, departamentele și board-ul).
2. Completează `SB_URL` și `SB_KEY` (cheia anon) la începutul scriptului din `index.html`. Nu folosi niciodată cheia service_role.
3. Activează GitHub Pages (Settings → Pages → branch `main`, folder `/root`) și pune adresa ca Site URL în Supabase (Authentication → URL Configuration).
4. Înregistrează-te în aplicație, apoi în SQL Editor:
   `update profiles set role='admin', status='activ' where email='emailul-tau';`
5. Aprobă restul conturilor din secțiunea „Conturi și acces”.

## Roluri
- `voluntar` – acces doar la contul propriu și la orele proprii (adăugare și vizualizare).
- `board` / `admin` – acces complet, aprobare conturi, validare ore, audit log.

## Stare
Autentificarea și rolurile folosesc Supabase. Modulele din interfață (voluntari, cereri, filiale, structură, ore) se salvează încă în localStorage; urmează migrarea lor pe tabele.

## Task-uri
Board-ul atribuie task-uri cu termen din „Taskuri voluntari”; voluntarul le vede în „Task-urile mele”, le marchează „În lucru” / „Finalizat” și vede termenul, zilele rămase sau întârzierea.
Dacă ai rulat deja `schema.sql` înainte, rulează în plus `tasks_update.sql`. Pe un proiect nou este deja inclus în `schema.sql`.
