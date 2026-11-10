-- DNT VOLUNTEER HUB - task-uri pentru voluntari (board atribuie, voluntarul finalizeaza)
-- Daca ai rulat deja schema.sql: ruleaza doar acest fisier. Pe un proiect nou este deja inclus in schema.sql.
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
