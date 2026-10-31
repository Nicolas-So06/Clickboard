-- Políticas de segurança do bucket de documentos do ClickBoard (Sprint 2 / T3).
-- Revogam a escrita anônima: leitura é pública, mas inserir, atualizar e apagar
-- exigem um usuário autenticado. Ajuste 'documents' para o nome real do bucket.

create policy "documents_public_read"
  on storage.objects for select
  using (bucket_id = 'documents');

create policy "documents_authenticated_insert"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'documents');

create policy "documents_authenticated_update"
  on storage.objects for update
  to authenticated
  using (bucket_id = 'documents');

create policy "documents_authenticated_delete"
  on storage.objects for delete
  to authenticated
  using (bucket_id = 'documents');
