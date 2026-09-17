# CKA-PREP

Hands-on CKA practice labs aligned with the [CKA video playlist](https://www.youtube.com/watch?v=-rs3AoAVyXE&list=PLkDZsCgo3Isr4NB5cmyqG7OZwYEx5XOjM). 17 exam-style questions, each with a Killercoda lab setup, step-by-step solution notes, and an auto-grading `validate.sh`.

## One-time setup (Killercoda)

Open https://killercoda.com/playgrounds/scenario/cka and run:

```bash
git clone https://github.com/abdalrahmanx9/CKA-PREP && cd CKA-PREP && chmod +x run.sh Question-*/validate.sh
```

On an existing session, refresh with `cd ~/CKA-PREP && git pull`.

## Usage

```bash
./run.sh 1           # set up lab 1 + show the question
./run.sh 1 hint      # solution notes if stuck
./run.sh 1 check     # validate your answer
```

## Questions

| # | Folder | Topic |
|---|--------|-------|
| 01 | Question-01-ArgoCD | Install Argo CD with Helm (no CRDs) |
| 02 | Question-02-Sidecar | Sidecar log container |
| 03 | Question-03-Gateway-API | Migrate Ingress to Gateway API |
| 04 | Question-04-Resource-Allocation | Pod resource requests/limits |
| 05 | Question-05-Storage-Class | Storage classes & PVCs |
| 06 | Question-06-PriorityClass | Priority classes |
| 07 | Question-07-Ingress | Ingress resources |
| 08 | Question-08-CRDs | Custom Resource Definitions |
| 09 | Question-09-Network-Policy | Network policies |
| 10 | Question-10-HPA | Horizontal Pod Autoscaler |
| 11 | Question-11-CNI-NetworkPolicy | Install a CNI |
| 12 | Question-12-MariaDB-PersistentVolume | Restore MariaDB with PV |
| 13 | Question-13-Cri-Dockerd | cri-dockerd node setup |
| 14 | Question-14-Etcd-Fix | Fix etcd / apiserver |
| 15 | Question-15-Taints-Tolerations | Taints & tolerations |
| 16 | Question-16-NodePort | NodePort services |
| 17 | Question-17-TLS-Config | TLS in deployments |

## Notes

- Most labs run concurrently in one Killercoda session, but **start a fresh session** for labs that modify or break cluster components: 01 (ArgoCD), 11 (CNI), 13 (cri-dockerd), 14 (etcd).
- Each `Questions.bash` lists one or more video walkthrough links.
- `SolutionNotes.bash` favors exam-appropriate commands (`kubectl patch` over `kubectl edit`).

## Credits

Questions and labs based on [CameronMetcalfe22/CKA-PREP](https://github.com/CameronMetcalfe22/CKA-PREP) and [vj2201/CKA-PREP-2025-v2](https://github.com/vj2201/CKA-PREP-2025-v2), derived from the [CKA video playlist](https://www.youtube.com/watch?v=-rs3AoAVyXE&list=PLkDZsCgo3Isr4NB5cmyqG7OZwYEx5XOjM).

