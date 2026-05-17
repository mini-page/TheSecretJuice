# 🛡️ Security Pack

Protect your data with professional-grade encryption and permission locking tools.

**Folder:** `Steroids/`

## 🛡️ Included Modules

The Security Pack combines two powerful yet distinct approaches to data protection:

### 1. `cipher-enhance.ps1` (EFS Encryption)
- **Command:** `cipher`
- **Category:** **High Security (Encryption)**
- **What it does:** Uses Windows **Encrypting File System (EFS)** to scramble the actual bits of your files. Without your Windows login or certificate, the data is unreadable even if the disk is stolen.
- **Best for:** Protecting sensitive documents, passwords, and private media from hackers or physical theft.
- **[View Detailed Guide](../modules/cipher-enhance.md)**

### 2. `acllock-enhance.ps1` (Permission Locking)
- **Command:** `acllock` / `lock`
- **Category:** **Access Control (Locking)**
- **What it does:** Modifies **Access Control Lists (ACL)** to deny access to "Everyone". It's like putting a padlock on a folder.
- **Best for:** Quickly hiding or locking folders from other users on the same machine.
- **[View Detailed Guide](../modules/acllock-enhance.md)**

---

## ⚖️ Which one should I use?

| Use Case | Recommended Tool | Why? |
| :--- | :--- | :--- |
| **Hiding a folder from a sibling/coworker** | `acllock` | Fast, easy to toggle, no complex certificates. |
| **Storing bank statements/passwords** | `cipher` | Provides actual bit-level encryption. |
| **Preventing unauthorized accidental deletes** | `acllock` | Deny rules prevent deletion by anyone. |
| **Protecting files on a USB drive** | `cipher` | Data remains encrypted if the drive is lost. |

---

## 🚀 Combined Quick Start

```powershell
# Interactive Encryption
cipher

# Interactive Locking
lock

# Check Status of a folder
lock status "C:\MyData"
cipher-status "C:\MyData"
```

---

**Part of TheSecretJuice** 💉 by [mini-page](https://github.com/mini-page)
