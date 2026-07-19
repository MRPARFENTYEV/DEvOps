# Скриншоты для защиты диплома

Сюда складываются скриншоты, на которые ссылается [`../DIPLOMA.md`](../DIPLOMA.md).
Имена файлов — строго как в таблице ниже (тогда ссылки в документе заработают сами).

Чтобы вставить скриншот в `DIPLOMA.md`, раскомментируй строку `<!-- вставь: ![...](...) -->`
в соответствующем блоке `📸 СКРИНШОТ`.

Кадры с суффиксами **a/b** — это пары «было → стало» (демонстрация создания с нуля).

| № | Имя файла | Что должно быть на кадре | Как получить |
|---|---|---|---|
| 01 | `01-bootstrap-apply.png` | Итог `terraform apply` в bootstrap: созданы SA, бакет, registry | Терминал в `diploma-infra/bootstrap` |
| 02 | `02-pr-plan-comment.png` | Комментарий пайплайна с `Terraform Plan` в pull request | Страница PR на GitHub |
| 03 | `03-actions-tf-apply.png` | Успешный `terraform apply` в GitHub Actions | Actions → workflow «Terraform infra» на push в main |
| 04a | `04a-yc-console-before.png` | БЫЛО: пустая консоль ЯО (нет ВМ/сетей/бакетов/registry) | Веб-консоль ЯО до `terraform apply` |
| 04b | `04b-yc-console-after.png` | СТАЛО: 3 ВМ, VPC, бакет, registry | Та же консоль ЯО после `terraform apply` |
| 05a | `05a-cluster-before.png` | БЫЛО: ВМ есть, кластера нет (`kubectl` не отвечает) | До Kubespray |
| 05b | `05b-cluster-after.png` | СТАЛО: `kubectl get nodes` (3 Ready) + `get pods -A` | Терминал с kubeconfig после Kubespray |
| 06a | `06a-ycr-before.png` | БЫЛО: реестр YCR пуст | Консоль ЯО (YCR) до сборки |
| 06b | `06b-ycr-after.png` | СТАЛО: образ `diploma-app` в реестре | Консоль ЯО (YCR) или `yc container image list` |
| 07 | `07-actions-ci-build.png` | CI: тесты + сборка + push образа | Actions в `diploma-app` на push |
| 08 | `08-actions-cd-deploy.png` | CD: деплой по тегу `vX.Y.Z` (`kubectl rollout status`) | Actions в `diploma-app` на тег |
| 09a | `09a-app-before.png` | БЫЛО: `app.<IP>.nip.io` недоступно | Браузер до деплоя |
| 09b | `09b-app-after.png` | СТАЛО: страница приложения отдаётся | `http://app.<IP>.nip.io/` |
| 10 | `10-grafana-k8s.png` | Grafana: дашборд состояния Kubernetes | Grafana → дашборд kube-prometheus |
| 11 | `11-grafana-app.png` | Grafana: кастомный дашборд «Diploma App» | Grafana → дашборд приложения |

> Совет: делай скриншоты в высоком разрешении и обрезай лишнее. Перед публикацией убедись,
> что в кадр не попали секреты (токены, ключи, пароли).
