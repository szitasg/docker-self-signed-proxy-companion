#!/bin/bash

function reload_nginx() {
    local _nginx_proxy_container="${NGINX_PROXY_CONTAINER:-}"

    if [[ -n "${_nginx_proxy_container:-}" ]]; then
        echo "Reloading nginx proxy (${_nginx_proxy_container})..."
        docker_exec "${_nginx_proxy_container}" \
            '[ "sh", "-c", "/app/docker-entrypoint.sh /usr/local/bin/docker-gen /app/nginx.tmpl /etc/nginx/conf.d/default.conf; /usr/sbin/nginx -s reload" ]' |
            sed -rn 's/^.*([0-9]{4}\/[0-9]{2}\/[0-9]{2}.*$)/\1/p'

        [[ "${PIPESTATUS[0]}" -eq 1 ]] \
            && echo "$(date "+%Y/%m/%d %T"), " \
                "Error: can't reload nginx-proxy." >&2
    fi
}

function docker_api() {
    local _scheme
    local _curl_opts=(-s)
    local _method="${2:-GET}"

    if [[ -n "${3:-}" ]]; then
        _curl_opts+=(-d "${3}")
    fi

    if [[ -z "${DOCKER_HOST}" ]]; then
        echo "Error DOCKER_HOST variable not set" >&2
        return 1
    elif [[ "${DOCKER_HOST}" == unix://* ]]; then
        _curl_opts+=(--unix-socket "${DOCKER_HOST#unix://}")
        _scheme='http://localhost'
    else
        _scheme="http://${DOCKER_HOST#*://}"
    fi

    [[ "${_method}" == "POST" ]] \
        && _curl_opts+=(-H 'Content-Type: application/json')

    curl "${_curl_opts[@]}" -X"${_method}" "${_scheme}${1}"
}

function docker_exec() {
    local _id="${1?missing _id}"
    local _cmd="${2?missing command}"
    local _data="$(printf '{ "AttachStdin": false, "AttachStdout": true, "AttachStderr": true, "Tty":false,"Cmd": %s }' "${_cmd}")"

    exec_id=$(docker_api "/containers/${_id}/exec" "POST" "${_data}" | jq -r .Id)

    if [[ -n "${exec_id}" && "${exec_id}" != "null" ]]; then
        docker_api "/exec/${exec_id}/start" "POST" '{"Detach": false, "Tty":false}'
    else
        echo "$(date "+%Y/%m/%d %T"), " \
            "Error: can't exec command ${_cmd} in container ${_id}. " \
            "Check if the container is running." >&2
        return 1
    fi
}
