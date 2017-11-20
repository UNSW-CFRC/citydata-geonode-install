select distinct title_en
from  geonode.public.layers_layer,
      geonode.public.people_profile,
      geonode.public.groups_groupmember,
      geonode.public.guardian_userobjectpermission,
      geonode.public.guardian_groupobjectpermission,
      geonode.public.auth_permission
where username = 'jdoig'
and auth_permission.name = 'Can download resource'
and (
  people_profile.id = guardian_userobjectpermission.user_id
  and guardian_userobjectpermission.object_pk = to_char(layers_layer.resourcebase_ptr_id,'FM99999999999')
  and guardian_userobjectpermission.permission_id = auth_permission.id
  );
-- or (
--   people_profile.id = groups_groupmember.user_id
--   and people_profile.id = guardian_groupobjectpermission.group_id
--   and guardian_groupobjectpermission.object_pk = to_char(layers_layer.resourcebase_ptr_id,'FM99999999999')
--   and guardian_groupobjectpermission.permission_id = auth_permission.id
--   ));