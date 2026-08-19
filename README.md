# NatCookies

[![iOS Build Verification](https://github.com/JhonHTipas21/Natcookies-App/actions/workflows/ios.yml/badge.svg)](https://github.com/JhonHTipas21/Natcookies-App/actions/workflows/ios.yml)

NatCookies es una aplicacion nativa para iOS diseñada para la gestion operativa y financiera de reposterias artesanales. La herramienta permite controlar el inventario de productos, registrar transacciones de ingresos y gastos, administrar cuentas por cobrar o pagar (fiados), calcular ganancias netas disponibles en tiempo real y simular precios de venta mediante margenes operativos.

---

## Arquitectura y Principios de Diseño

El proyecto ha sido refactorizado bajo una **Arquitectura Limpia (Clean Architecture)** acoplada al patron **MVVM (Model-View-ViewModel)**, asegurando que el codigo sea modular, altamente testeable y mantenible.

### Principios SOLID Aplicados:
* **Responsabilidad Unica (SRP)**: Cada clase y struct cumple una unica funcion. La logica de persistencia, negocio e interfaz se encuentran completamente separadas.
* **Inversion de Dependencias (DIP)**: Los servicios y ViewModels no instancian directamente bases de datos o sistemas de persistencia; interactuan a traves de protocolos (interfaces) inyectados por el constructor.
* **Segregacion de Interfaces (ISP)**: Los protocolos de almacenamiento estan divididos por dominio especifico (ProductRepository, TransactionRepository, DebtRepository, SavingsGoalRepository).

### Capas del Proyecto:
1. **Domain (Negocio)**: Contiene los modelos de datos inmutables, las interfaces de los repositorios y los servicios de negocio puros (`InventoryService`, `FinanceService`, `DebtService`) sin dependencias de frameworks de interfaz.
2. **Data (Persistencia)**: Implementa los almacenes fisicos. En esta version se utiliza `UserDefaultsDataStore` con reactividad nativa mediante Combine.
3. **Presentation (UI)**: Capa de vistas en SwiftUI estructuradas con sus respectivos ViewModels para el manejo de estado reactivo y mapeo de datos.
4. **App (Entrada)**: Administra el ciclo de vida de la aplicacion y configura la inyeccion de dependencias centralizada a traves de `DependencyContainer`.

---

## Modulos Principales

* **Tablero Principal (Dashboard)**: Visualizacion del balance de ingresos, gastos, costos de mano de obra y ganancias netas disponibles. Rendimiento semanal interactivo.
* **Caja de Flujo (Transactions)**: Historial completo de movimientos de caja (ventas y gastos) con filtrado dinamico.
* **Inventario (Inventory)**: Control de stock de materias primas y productos terminados con alertas automaticas de stock bajo.
* **Fiados (Debts)**: Administracion de deudas con clientes y proveedores, con opcion para enviar recordatorios de cobro estructurados por WhatsApp.
* **Finanzas (Finances)**: Simulador aislado de margenes operativos y seguimiento de metas de ahorro.

---

## Demostracion de Funcionamiento

A continuacion se presenta el video explicativo con el flujo operativo completo de la aplicacion:

<video src="https://github.com/user-attachments/assets/4629ad8f-2b47-4e30-94c1-6a1836805f54" width="100%" controls></video>

---

## Requisitos de Ejecucion

* iOS 16.0 o superior
* Xcode 16.0 o superior
* Swift 5.10 o superior

---

## Instalacion y Setup

1. Clone el repositorio en su maquina local:
   ```bash
   git clone git@github.com:JhonHTipas21/Natcookies-App.git
   ```
2. Abra el archivo del proyecto en Xcode:
   ```bash
   open NatCookies/NatCookies.xcodeproj
   ```
3. Seleccione el dispositivo de destino (Simulador o Dispositivo Fisico) y ejecute la aplicacion (`Cmd + R`).
