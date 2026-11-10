-- DNT VOLUNTEER HUB - schema completa. Ruleaza o singura data pe un proiect Supabase NOU.
create sequence vol_seq; create sequence cerere_seq; create sequence fil_seq;

create table public.profiles(id uuid primary key references auth.users(id) on delete cascade, nume text, prenume text, email text unique, avatar_url text,
 role text not null default 'voluntar' check (role in ('admin','presedinte','consiliu','birou_executiv','board','director_dep','hr','presedinte_filiala','vicepresedinte_filiala','secretar_filiala','coordonator_local','voluntar')),
 status text not null default 'in_asteptare' check (status in ('in_asteptare','activ','suspendat')), created_at timestamptz default now());
create table public.departments(id uuid primary key default gen_random_uuid(), nume text unique not null, descriere text, obiective text, director_id uuid references public.profiles(id), status text not null default 'activ', infiintat date, created_at timestamptz default now());
create table public.branches(id uuid primary key default gen_random_uuid(), cod text unique default 'FIL-'||lpad(nextval('fil_seq')::text,3,'0'), nume text not null, judet text not null, localitate text, infiintata date, aprobata date, presedinte_id uuid references public.profiles(id),
 status text not null default 'in_pregatire' check (status in ('in_pregatire','cerere_infiintare','in_analiza','aprobata','activa','suspendata','inactiva','desfiintata')), created_at timestamptz default now());
create table public.volunteers(id uuid primary key default gen_random_uuid(), cod text unique default 'DNT-V-'||lpad(nextval('vol_seq')::text,5,'0'), nr_inreg text, profile_id uuid references public.profiles(id),
 nume text not null, prenume text not null, email text, telefon text, judet text, localitate text, data_nasterii date, foto_url text,
 branch_id uuid references public.branches(id), department_id uuid references public.departments(id), functie text default 'Voluntar', pozitie text, coordonator_id uuid references public.volunteers(id),
 nivel text default 'local' check (nivel in ('national','judetean','local')),
 status text not null default 'candidat' check (status in ('candidat','in_verificare','aprobat','activ','inactiv','suspendat','retras','respins')),
 data_inscriere date default current_date, data_aprobare date, data_start date, data_incetare date, arhivat boolean not null default false, created_at timestamptz default now());
create table public.projects(id uuid primary key default gen_random_uuid(), nume text not null, descriere text, department_id uuid references public.departments(id), branch_id uuid references public.branches(id), responsabil_id uuid references public.profiles(id), status text default 'propus', buget numeric, data_start date, data_sfarsit date, created_at timestamptz default now());
create table public.volunteer_applications(id uuid primary key default gen_random_uuid(), nr_cerere text unique default 'CR-'||to_char(now(),'YYYY')||'-'||lpad(nextval('cerere_seq')::text,5,'0'),
 nume text not null, prenume text not null, email text not null, telefon text, judet text, localitate text, categorie_varsta text, institutie text, experienta text, domenii text[], departament_dorit text, branch_dorit uuid references public.branches(id), motivatie text, disponibilitate text, cv_path text,
 acord_gdpr boolean not null check (acord_gdpr), acord_parental boolean default false, check (categorie_varsta is distinct from 'sub_18' or acord_parental),
 status text not null default 'noua' check (status in ('noua','in_verificare','completari','aprobata','respinsa')), reviewed_by uuid references public.profiles(id), volunteer_id uuid references public.volunteers(id), created_at timestamptz default now());
create table public.volunteer_status_history(id uuid primary key default gen_random_uuid(), volunteer_id uuid not null references public.volunteers(id) on delete cascade, status_vechi text, status_nou text, motiv text, changed_by uuid default auth.uid(), created_at timestamptz default now());
create table public.volunteer_positions_history(id uuid primary key default gen_random_uuid(), volunteer_id uuid not null references public.volunteers(id) on delete cascade, branch_id uuid references public.branches(id), department_id uuid references public.departments(id), functie text, de_la date, pana_la date, created_by uuid default auth.uid());
create table public.volunteer_hours(id uuid primary key default gen_random_uuid(), user_id uuid not null references public.profiles(id), volunteer_id uuid references public.volunteers(id), branch_id uuid references public.branches(id), department_id uuid references public.departments(id), project_id uuid references public.projects(id),
 data date not null, proiect text not null, descriere text, ore numeric not null check (ore>0 and ore<=24), coordonator text, validat boolean not null default false, validat_de uuid references public.profiles(id), created_at timestamptz default now());
create table public.branch_applications(id uuid primary key default gen_random_uuid(), judet text not null, localitate text, initiator_id uuid references public.profiles(id), echipa jsonb, nr_persoane int, structura text, motivare text, plan_activitate text, documente jsonb,
 status text not null default 'cerere_infiintare', decis_de uuid references public.profiles(id), branch_id uuid references public.branches(id), created_at timestamptz default now());
create table public.branch_members(id uuid primary key default gen_random_uuid(), branch_id uuid not null references public.branches(id) on delete cascade, profile_id uuid not null references public.profiles(id), role text not null default 'membru' check (role in ('presedinte','vicepresedinte','secretar','coordonator','membru')), unique(branch_id,profile_id));
create table public.branch_structures(id uuid primary key default gen_random_uuid(), branch_id uuid not null references public.branches(id) on delete cascade, department_id uuid references public.departments(id), nume text, responsabil_id uuid references public.profiles(id));
create table public.department_members(id uuid primary key default gen_random_uuid(), department_id uuid not null references public.departments(id) on delete cascade, profile_id uuid not null references public.profiles(id), rol text default 'membru', unique(department_id,profile_id));
create table public.organizational_positions(id uuid primary key default gen_random_uuid(), nume text not null, nivel text, department_id uuid references public.departments(id), activ boolean default true);
create table public.national_board(id uuid primary key default gen_random_uuid(), grup text not null check (grup in ('birou_executiv','consiliu_director','comisie_etica','cenzori')), pozitie text not null, department_id uuid references public.departments(id), profile_id uuid references public.profiles(id), nume_titular text, mandat_start date, mandat_end date, created_at timestamptz default now());
create table public.documents(id uuid primary key default gen_random_uuid(), nr_inreg text, categorie text not null, titlu text not null, data date default current_date, emitent text, responsabil_id uuid references public.profiles(id), fisier_path text, branch_id uuid references public.branches(id), created_by uuid default auth.uid(), created_at timestamptz default now());
create table public.document_register(id uuid primary key default gen_random_uuid(), tip text check (tip in ('intrare','iesire')), nr text, data date default current_date, document_id uuid references public.documents(id), expeditor text, destinatar text, obiect text);
create table public.meetings(id uuid primary key default gen_random_uuid(), titlu text not null, tip text, data timestamptz, branch_id uuid references public.branches(id), department_id uuid references public.departments(id), participanti jsonb, proces_verbal_id uuid references public.documents(id), created_by uuid default auth.uid());
create table public.activities(id uuid primary key default gen_random_uuid(), project_id uuid references public.projects(id), branch_id uuid references public.branches(id), titlu text not null, data date, descriere text);
create table public.tasks(id uuid primary key default gen_random_uuid(), titlu text not null, department_id uuid references public.departments(id), project_id uuid references public.projects(id), asignat_id uuid references public.profiles(id), status text default 'deschis', termen date, created_by uuid default auth.uid());
create table public.evaluations(id uuid primary key default gen_random_uuid(), volunteer_id uuid not null references public.volunteers(id), evaluator_id uuid default auth.uid(), perioada_start date, perioada_end date, indicatori jsonb, comentarii text, created_at timestamptz default now());
create table public.notifications(id uuid primary key default gen_random_uuid(), profile_id uuid not null references public.profiles(id) on delete cascade, titlu text, mesaj text, citit boolean default false, created_at timestamptz default now());
create table public.audit_logs(id bigint generated always as identity primary key, user_id uuid default auth.uid(), actiune text not null, tabel text, record_id text, detalii jsonb, created_at timestamptz default now());

create index on public.volunteers(branch_id); create index on public.volunteers(department_id); create index on public.volunteers(status); create index on public.volunteers(judet);
create index on public.volunteer_applications(status); create index on public.volunteer_hours(user_id); create index on public.volunteer_hours(validat);
create index on public.branch_members(profile_id); create index on public.national_board(grup); create index on public.audit_logs(created_at desc); create index on public.notifications(profile_id);

-- Functii de acces
create function public.is_board() returns boolean language sql security definer set search_path=public stable as $$ select exists(select 1 from profiles where id=auth.uid() and status='activ' and role in ('admin','presedinte','consiliu','birou_executiv','board')) $$;
create function public.is_hr() returns boolean language sql security definer set search_path=public stable as $$ select public.is_board() or exists(select 1 from profiles where id=auth.uid() and status='activ' and role='hr') $$;
create function public.in_branch_staff(b uuid) returns boolean language sql security definer set search_path=public stable as $$ select exists(select 1 from branch_members m join profiles p on p.id=m.profile_id where m.profile_id=auth.uid() and m.branch_id=b and m.role in ('presedinte','vicepresedinte','secretar','coordonator') and p.status='activ') $$;
create function public.handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$ begin insert into public.profiles(id,nume,prenume,email) values(new.id,new.raw_user_meta_data->>'nume',new.raw_user_meta_data->>'prenume',new.email); return new; end $$;
create trigger on_auth_user_created after insert on auth.users for each row execute function public.handle_new_user();
create function public.audit_row() returns trigger language plpgsql security definer set search_path=public as $$ begin insert into audit_logs(user_id,actiune,tabel,record_id,detalii) values(auth.uid(),tg_op,tg_table_name,coalesce(to_jsonb(new)->>'id',to_jsonb(old)->>'id'),case tg_op when 'DELETE' then to_jsonb(old) else to_jsonb(new) end); return coalesce(new,old); end $$;
create function public.vol_status_hist() returns trigger language plpgsql security definer set search_path=public as $$ begin insert into volunteer_status_history(volunteer_id,status_vechi,status_nou) values(new.id,old.status,new.status); return new; end $$;
create trigger t_vol_status after update on public.volunteers for each row when (old.status is distinct from new.status) execute function public.vol_status_hist();

-- Audit automat (cine, ce, cand) + RLS "board are acces complet" pe toate tabelele
do $$ declare t text; begin
 foreach t in array array['volunteers','volunteer_applications','branches','branch_applications','branch_members','departments','department_members','national_board','documents','document_register','projects','profiles','evaluations'] loop
  execute format('create trigger audit_%1$s after insert or update or delete on public.%1$I for each row execute function public.audit_row()',t); end loop;
 foreach t in array array['departments','branches','volunteers','volunteer_applications','volunteer_status_history','volunteer_positions_history','volunteer_hours','branch_applications','branch_members','branch_structures','department_members','organizational_positions','national_board','documents','document_register','meetings','projects','activities','tasks','evaluations','notifications'] loop
  execute format('alter table public.%I enable row level security',t);
  execute format('create policy board_all on public.%I for all using (public.is_board()) with check (public.is_board())',t); end loop;
end $$;
alter table public.profiles enable row level security; alter table public.audit_logs enable row level security;

create policy p_sel on public.profiles for select using (id=auth.uid() or public.is_hr());
create policy p_upd on public.profiles for update using (public.is_board()) with check (public.is_board());
create policy v_own on public.volunteers for select using (profile_id=auth.uid());
create policy v_hr on public.volunteers for all using (public.is_hr()) with check (public.is_hr());
create policy v_bsel on public.volunteers for select using (public.in_branch_staff(branch_id));
create policy v_bupd on public.volunteers for update using (public.in_branch_staff(branch_id)) with check (public.in_branch_staff(branch_id));
create policy a_pub on public.volunteer_applications for insert to anon, authenticated with check (status='noua' and volunteer_id is null);
create policy a_hr on public.volunteer_applications for all using (public.is_hr()) with check (public.is_hr());
create policy a_br on public.volunteer_applications for select using (public.in_branch_staff(branch_dorit));
create policy b_staff on public.branches for select using (public.in_branch_staff(id));
create policy ba_own on public.branch_applications for insert to authenticated with check (initiator_id=auth.uid());
create policy h_sel on public.volunteer_hours for select using (user_id=auth.uid() or public.is_hr());
create policy h_ins on public.volunteer_hours for insert with check (user_id=auth.uid() and validat=false);
create policy n_own on public.notifications for select using (profile_id=auth.uid());
create policy n_upd on public.notifications for update using (profile_id=auth.uid()) with check (profile_id=auth.uid());
create policy e_hr on public.evaluations for all using (public.is_hr()) with check (public.is_hr());
create policy au_sel on public.audit_logs for select using (public.is_board());
create policy au_ins on public.audit_logs for insert with check (user_id=auth.uid());
revoke update, delete, truncate on public.audit_logs from anon, authenticated;

-- Stocare fisiere (privata)
insert into storage.buckets(id,name,public) values ('documente','documente',false),('cv','cv',false),('avatare','avatare',false) on conflict do nothing;
create policy s_doc on storage.objects for all using (bucket_id='documente' and public.is_board()) with check (bucket_id='documente' and public.is_board());
create policy s_cv_ins on storage.objects for insert to anon, authenticated with check (bucket_id='cv');
create policy s_cv_sel on storage.objects for select using (bucket_id='cv' and public.is_hr());
create policy s_av on storage.objects for all to authenticated using (bucket_id='avatare' and (storage.foldername(name))[1]=auth.uid()::text) with check (bucket_id='avatare' and (storage.foldername(name))[1]=auth.uid()::text);

-- Date initiale: departamente + board (editabile). Nu exista filiale sau voluntari preincarcati.
insert into public.departments(nume) select unnest(array['Secretariat','Finanțe','Organizare Internă','Relații Externe','Proiecte','Parteneriate și Sponsorizări','Advocacy și Comunicare Juridică','Resurse Umane']);
insert into public.national_board(grup,pozitie,department_id,nume_titular)
select v.g,v.p,(select id from public.departments d where d.nume=v.d),v.n from (values
('birou_executiv','Președinte',null::text,'Andrei-Denis Ionescu'),('birou_executiv','Secretar General','Secretariat',null),('birou_executiv','Secretar General','Finanțe','Alexandru Popescu'),
('birou_executiv','Vicepreședinte','Organizare Internă',null),('birou_executiv','Vicepreședinte','Relații Externe',null),('birou_executiv','Vicepreședinte','Proiecte','Alexia Bușe'),
('birou_executiv','Vicepreședinte','Parteneriate și Sponsorizări',null),('birou_executiv','Vicepreședinte','Advocacy și Comunicare Juridică','Daria-Maria Hera'),('birou_executiv','Vicepreședinte','Resurse Umane',null),
('consiliu_director','Membru',null,'Daria-Maria Hera'),('consiliu_director','Membru',null,'Alexia Bușe'),('consiliu_director','Membru',null,'Alexandru Popescu'),
('comisie_etica','Membru',null,'Rania Daoud'),('comisie_etica','Membru',null,null),('comisie_etica','Membru',null,null),
('cenzori','Cenzor',null,null),('cenzori','Cenzor',null,null),('cenzori','Cenzor',null,null)) v(g,p,d,n);

-- ===== TASK-URI =====
alter table public.tasks add column if not exists descriere text;
alter table public.tasks add column if not exists finalizat_la timestamptz;
alter table public.tasks alter column status set default 'deschis';
update public.tasks set status='deschis' where status is null or status not in ('deschis','in_lucru','finalizat');
alter table public.tasks drop constraint if exists tasks_status_chk;
alter table public.tasks add constraint tasks_status_chk check (status in ('deschis','in_lucru','finalizat'));
create index if not exists tasks_asignat_idx on public.tasks(asignat_id, termen);

drop policy if exists t_own on public.tasks;
create policy t_own on public.tasks for select using (asignat_id=auth.uid() and exists(select 1 from public.profiles where id=auth.uid() and status='activ'));

-- Voluntarul poate schimba DOAR statusul propriilor task-uri (nu titlul, termenul sau persoana)
create or replace function public.set_task_status(tid uuid, st text) returns void language plpgsql security definer set search_path=public as $$
begin
  if st not in ('deschis','in_lucru','finalizat') then raise exception 'status invalid'; end if;
  update tasks set status=st, finalizat_la=case when st='finalizat' then now() else null end
   where id=tid and (public.is_board() or (asignat_id=auth.uid() and exists(select 1 from profiles where id=auth.uid() and status='activ')));
  if not found then raise exception 'nu ai acces la acest task'; end if;
end $$;

drop trigger if exists audit_tasks on public.tasks;
create trigger audit_tasks after insert or update or delete on public.tasks for each row execute function public.audit_row();
