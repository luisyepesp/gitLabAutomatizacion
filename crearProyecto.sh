#!/bin/bash

token="TOKEN"

function usage {
  echo "se utiliza asi: $0 -n nombre del proyecto"
  exit 1
}

number_args=$#
if [[ !("$number_args" -eq 2) ]]; then
  echo "se deben pasar dos argumentos" >&2
  usage
fi

while getopts "n:" name; do
  case "${name}" in
    n)
      repo=${OPTARG}
      ;;
    \?)
      usage
      ;;
    *)
      usage
      ;;
  esac
done

if [[ -z ${repo} ]]; then
  echo "falta el argumento -n " >&2
  usage
else
  echo "#######\nProyecto Creandose: ${repo}\n#######\n"
fi

repo_short=$(echo ${repo} | cut -d " " -f1)

response=$(curl -s -o ./temp.json -w '%{http_code}' \
-H "Content-Type:application/json" https://gitlab.com/api/v4/projects?private_token=$token \
-d "{ \"name\": \"${repo}\" }")

# Format JSON log
cat ./temp.json | python -m json.tool > ./${repo_short}_repo.json
rm -f ./temp.json

echo "Any JSON output is logged in ./${repo_short}_repo.json"
if [ $response != 201 ]; then
  echo "Error\nCODIGO RESPUESTA: $response"
  exit 1
else
  echo "Proyecto creado"
  echo "Que proyecto deseas Clonar?"
  read proyectoClon
  git clone https://gitlab.com:key@gitlab.com/luisyepesp/$proyectoClon.git
  mv $proyectoClon $repo
  chmod +x $repo
  cd $repo
  git remote rm origin
  git remote add origin https://gitlab.com/luisyepesp/$repo.git
  git add .
  git commit -m "PROYECTO INICIAL"
  git push -u origin main
  cd ..
  rm -rf $repo
  exit 0
fi
