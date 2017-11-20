For each u in
(
select distinct username
from layers_layer, people_profile, guardian_userobjectpermission, auth_permission
where username not in ('admin', 'AnonymousUser')
and people_profile.id = guardian_userobjectpermission.user_id
and auth_permission.name = 'Can download resource'
and guardian_userobjectpermission.object_pk = to_char(layers_layer.resourcebase_ptr_id,'FM99999999999')
and guardian_userobjectpermission.permission_id = auth_permission.id
order by username;
)

{
create user $username with password $password

select distinct username, layers_layer.name
from layers_layer, people_profile, guardian_userobjectpermission, auth_permission
where username not in ('admin', 'AnonymousUser')
and people_profile.id = guardian_userobjectpermission.user_id
and auth_permission.name = 'Can download resource'
and guardian_userobjectpermission.object_pk = to_char(layers_layer.resourcebase_ptr_id,'FM99999999999')
and guardian_userobjectpermission.permission_id = auth_permission.id
order by username, layers_layer.name;