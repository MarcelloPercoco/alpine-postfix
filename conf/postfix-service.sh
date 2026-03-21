#!/bin/sh

log() {
  echo "$(date) $ME - $@"
}

serviceConf() {
  # Controlla la variabile hostname con un costrutto case (esente da regex bash)
  case "${HOSTNAME}" in
    *.*) ;;
    *) HOSTNAME="${HOSTNAME}.${DOMAIN}" ;;
  esac

  # Sostituzione delle variabili con costrutti POSIX standard
  for VARIABLE in $(env | cut -f1 -d=); do
    VAR=$(echo "$VARIABLE" | tr ':' '_')
    # Usa eval per simulare in modo sicuro l'espansione indiretta delle variazioni (${!VAR})
    eval VAL="\$${VARIABLE}"
    sed -i "s={{ $VAR }}=${VAL}=g" /etc/postfix/*.cf
  done

  # Override Postfix configuration usando grep per scartare commenti e righe vuote
  if [ -f /overrides/postfix.cf ]; then
    grep -vE '^[[:space:]]*(#|$)' /overrides/postfix.cf | while IFS= read -r line; do
      postconf -e "$line"
    done
    echo "Loaded '/overrides/postfix.cf'"
  else
    echo "No extra postfix settings loaded because optional '/overrides/postfix.cf' not provided."
  fi

  # Include file delle mappe
  if ls -A /overrides/*.map > /dev/null 2>&1; then
    cp /overrides/*.map /etc/postfix/
    postmap /etc/postfix/*.map
    rm /etc/postfix/*.map
    chown root:root /etc/postfix/*.db
    chmod 0600 /etc/postfix/*.db
    echo "Loaded 'map files'"
  else
    echo "No extra map files loaded because optional '/overrides/*.map' not provided."
  fi
}

serviceStart() {
  serviceConf
  # Avvia effettivamente Postfix
  log "[ Starting Postfix... ]"
  /usr/sbin/postfix start-fg 
}

export DOMAIN=${DOMAIN:-"localdomain"}
export HOSTNAME=${HOSTNAME:-"localhost"}
export MESSAGE_SIZE_LIMIT=${MESSAGE_SIZE_LIMIT:-"50000000"}
export RELAYNETS=${RELAYNETS:-""}
export RELAYHOST=${RELAYHOST:-""}

# Redirezione standard 1 e 2 per /bin/sh
serviceStart >> /proc/1/fd/1 2>&1