# Auditoría local de seguridad

Compatible con Devuan/SysVinit/XFCE y Void/runit/Sway. Solo biblioteca estándar
de Python 3 e interfaces habituales de Linux. No instala paquetes, no modifica
firewall/SSH/sysctl, no lee contraseñas WiFi ni claves privadas completas y no
hace barridos de red. No es un antivirus, un IDS ni una certificación de seguridad.

## Uso

```sh
security-scan                 # informe nuevo, normalmente unos segundos
security-show -m 8            # resumen del último, también si es de hoy
security-show                # hallazgos, acciones y limitaciones
security-show --verbose      # además inventario técnico
net_selfcheck.py --json       # motor local sin guardar informe
wifi_selfcheck.py --json      # motor WiFi pasivo sin guardar informe
```

Los scripts se usan como usuario normal. Los códigos de salida 0/1/2 significan
sin hallazgos / avisos / hallazgos críticos. Un 0 no borra los «no verificados»:
estos siempre aparecen por separado y nunca se convierten en «protegido».

Informes privados y separados por equipo:
`~/Logs/security/HOST/YYYY-MM-DD_HHMMSS_microseconds.{json,log}` y `latest.{json,log}`.
El JSON guarda evidencia estructurada, duración, cobertura, diferencias y motivo
(manual/login/logout/shutdown/periodic). `~/Logs/security/latest.log` queda como
copia de compatibilidad. No se incluyen comandos completos de procesos ni secretos.

## Qué cambia respecto a los scripts anteriores

- Se evalúan también listeners ligados a una IP LAN concreta, no solo 0.0.0.0.
- Tener UFW/nft instalado no prueba que haya filtrado. Se inspeccionan políticas
  INPUT IPv4/IPv6; ni Docker FORWARD ni una política drop garantizan excepciones seguras.
- `sshd -T -C` interpreta defaults e Includes. No se toma la última línea de
  sshd_config como configuración efectiva. El contexto de prueba usa el usuario
  local y una dirección documental externa: bloques Match pueden variar por origen.
- `rp_filter` se calcula como max(all, interfaz) sobre interfaces de ruta por defecto.
  El valor de `default` no evalúa interfaces que ya existen. 0 merece revisión,
  no alarma de intrusión; 2 es flexible y 1 estricto. IPv6 no utiliza este sysctl.
- No se señala `.cache/uv/.lock` como exposición cuando un ancestro 0700 impide
  acceder a otros usuarios. Se priorizan claves, scripts/rutas de ejecución e historial.
- WiFi distingue disconnected de connected. WPA-PSK no prueba WPA2. Se intenta
  leer el cifrado negociado; si solo existe evidencia del perfil/AP se declara.
- Sin WiFi, poca señal, ping bloqueado, número de vecinos y nombres DNS no se
  presentan como vulnerabilidades. No hay rescan, ping-sweep ni sondeo del router.
- APT y XBPS se consultan sin descargar metadata. Se avisa de índices antiguos y
  componentes sensibles pendientes, sin inventar CVEs.

## Servicios y primera terminal

El `.zshrc` común llama `security-show --once -m 8` en una terminal interactiva.
La marca de sesión está en ~/Logs y se distingue por boot y sesión, no por fecha:
cerrar y volver a iniciar sesión el mismo día puede volver a mostrar el resumen.
Antes de Sway en un login TTY también se mantiene el aviso.

`security-session --install-desktop` instala el autostart XDG de XFCE. El daemon
de usuario toma una instantánea inicial si no existe informe y cada 30 minutos,
sin tráfico externo. Conserva el informe de cierre anterior para la primera terminal.
Ante TERM/HUP o SessionRemoved de su propia sesión elogind intenta una última
instantánea; el logout gráfico no garantiza
tiempo de ejecución, por eso se conservan las periódicas.

En Devuan el gancho fiable para apagado/reinicio normal es el servicio SysV:

```sh
~/Tools/services/devuan/activate ~/Tools/services/devuan/security-scan
# Si pide autorización:
sudo ~/Tools/services/devuan/security-scan/install
sudo /etc/init.d/security-scan status
sudo /etc/init.d/security-scan scan  # probar el mismo pipeline sin apagar
```

El instalador copia un init y un colector root-owned. El colector solo lee
sshd/nft/iptables con comandos fijos y plazos cortos; sus datos pasan por stdin al
analizador ejecutado SIN root. No se ejecuta código de Tools con privilegios root
durante la auditoría. El análisis de apagado tiene timeout de 20 s (+2 s de kill),
antes de parar NetworkManager, DBus, SLiM, SSH y Docker cuando existen.

Void conserva un servicio runit independiente:

```sh
~/Tools/services/void/activate ~/Tools/services/void/security-scan
```

No equivale a una unidad systemd. El orden de parada y el tiempo concedido por
runit pueden limitar la instantánea final: la de usuario es best-effort y las
periódicas cubren esa limitación. Un corte de luz o apagado forzado NO puede
ejecutar un análisis final, en ninguno de los dos sistemas.

## Política explícita

`policy.json` contiene los servicios ya usados en estos ordenadores (SSH,
Syncthing y mDNS). Una excepción solo indica «listener esperado», no «servicio
seguro». SSH sigue auditándose. Un puerto desconocido no prueba una intrusión.
Se pueden sobreescribir ajustes por host en `hosts/HOST.json`; no se aceptan
automáticamente nuevos listeners solo por aparecer en una instantánea.

## Pruebas

```sh
python3 -m unittest discover -s ~/Tools/tests -p test_security.py -v
```

Las pruebas usan homes temporales y datos sintéticos; no cambian seguridad real.
