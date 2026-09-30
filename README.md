# TheMazterDesing

Portafolio estático en español para miniaturas de YouTube. Incluye una portada pública y un panel de administración conectado a Supabase.

## Supabase: puesta en marcha

1. Crea un proyecto en Supabase.
2. Abre **SQL Editor**, pega y ejecuta el contenido de [`supabase-setup.sql`](supabase-setup.sql).
   Si el proyecto ya está conectado, vuelve a ejecutar este archivo para agregar soporte al orden manual de trabajos; conserva el contenido y los permisos existentes.
3. En **Authentication → Users**, crea un usuario administrador con correo y contraseña. Desactiva los registros públicos para que solo tú puedas entrar.
4. Copia el UUID de ese usuario y ejecuta en SQL Editor, reemplazando el marcador:

   ```sql
   insert into public.portfolio_admins (user_id)
   values ('UUID_DEL_USUARIO_ADMIN');
   ```

5. En **Project Settings → API Keys**, copia el **Project URL** y la clave pública **publishable** (o `anon` si tu proyecto aún usa las claves heredadas). Pégalos en [`supabase-config.js`](supabase-config.js).
6. Sube el cambio a GitHub. Al conectar ese repositorio con Vercel, Vercel publicará la portada y el panel. No hace falta añadir variables de entorno.
7. Abre `/Panel.html` en el dominio publicado e inicia sesión con el usuario administrador.

El panel pide inicio de sesión y solo usuarios agregados a `portfolio_admins` pueden crear, editar o borrar contenido. Las miniaturas se guardan en el bucket público `portfolio-thumbnails`; sus archivos son públicos para que la galería se pueda ver sin iniciar sesión. Las tablas aplican Row Level Security: lectura pública y escritura limitada al administrador.

## Publicar en Vercel

En Vercel selecciona **Add New → Project**, importa `Zazito0206/TheMazterDesing` desde GitHub, deja el framework como **Other** y el directorio raíz como `./`. El sitio no necesita build command. Cada push a `main` dispara una nueva publicación.

## Archivos

- `index.html`: portafolio público.
- `Panel.html`: administración de trabajos y creadores.
- `mazter-about.png`: imagen de la sección Sobre mí.
- `supabase-config.js`: URL y clave pública de Supabase.
- `supabase-client.js`: cliente compartido para lectura pública.
- `supabase-setup.sql`: tablas, políticas RLS y bucket de imágenes.

No pongas una clave `service_role` o una clave secreta en el sitio. La clave publishable/anon es para el navegador y debe usarse junto con las políticas RLS del SQL.

