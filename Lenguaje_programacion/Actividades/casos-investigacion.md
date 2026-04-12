# 📚 Casos de Investigación — C# / .NET

**Curso:** Lenguaje de Programación  
---

## Trabajos

- [Caso 1 — Spotify · POO y Patrones de Diseño](#caso-1--spotify--poo-y-patrones-de-diseño)
- [Caso 2 — Netflix · Arquitectura MVC y APIs REST](#caso-2--netflix--arquitectura-mvc-y-apis-rest)
- [Caso 3 — Uber · Estructuras de Datos y Algoritmos](#caso-3--uber--estructuras-de-datos-y-algoritmos)
- [Caso 4 — Microsoft Azure AD · Seguridad y Autenticación](#caso-4--microsoft-azure-ad--seguridad-y-autenticación)

GRUPOs:  
- Grupo 1  
- Grupo 2  
- Grupo 3  
- Grupo 4  
---

## Caso 1 — Spotify · POO y Patrones de Diseño

### Preguntas de investigación

1. ¿Qué relación existe entre los principios SOLID y el diseño de clases en C#? Explica cada principio con un ejemplo aplicado al dominio de Spotify.

2. Diseña en C# una jerarquía de clases para representar los tipos de contenido de Spotify. ¿Qué atributos y métodos compartiría la clase base? ¿Qué sobreescribirían las clases derivadas?

3. ¿Qué patrón de diseño usarías para notificar a los seguidores cuando un artista publica una nueva canción? Impleméntalo en C#.

4. ¿Cómo aplicarías el patrón Factory para crear instancias de distintos reproductores según el tipo de contenido y el plan del usuario (Free / Premium)?

5. ¿Qué ventajas tiene usar interfaces en C# frente a clases abstractas en este contexto? ¿Cuándo usarías una u otra?

6. Si el equipo de Spotify necesitara agregar un nuevo tipo de contenido (por ejemplo, audiolibros interactivos) sin modificar el código existente, ¿qué principio SOLID garantizaría eso y cómo lo implementarías?

7. Propón una mejora a la arquitectura de clases considerando escalabilidad y mantenibilidad a largo plazo.

8. Conclusiones individuales.

9. Bibliografía.

---

## Caso 2 — Netflix · Arquitectura MVC y APIs REST

### Preguntas de investigación

1. ¿Cómo separa ASP.NET Core las responsabilidades entre Model, View y Controller? Dibuja el flujo de una solicitud HTTP dentro de ese patrón.

2. Implementa en C# un controlador `PeliculasController` con al menos cuatro endpoints REST (`GET`, `POST`, `PUT`, `DELETE`). ¿Qué código de estado HTTP debería devolver cada uno y por qué?

3. ¿Qué diferencia hay entre una Web API y un MVC clásico en ASP.NET Core? ¿Cuándo conviene usar cada uno?

4. ¿Cómo se serializa y deserializa un objeto C# a JSON? Compara `System.Text.Json` con `Newtonsoft.Json` en rendimiento y flexibilidad.

5. ¿Qué es el versionado de APIs y por qué Netflix lo necesita? Muestra cómo implementarlo en ASP.NET Core.

6. ¿Cómo documentarías automáticamente la API usando Swagger/OpenAPI en .NET? ¿Qué beneficio tiene para un equipo de desarrollo?

7. Si diseñaran la API de una plataforma de video, ¿qué endpoints definirían, qué estructura de respuesta usarían y qué convenciones REST respetarían?

8. Conclusiones individuales.

9. Bibliografía.

---

## Caso 3 — Uber · Estructuras de Datos y Algoritmos

### Preguntas de investigación

1. ¿Qué es la complejidad algorítmica (Big O) y por qué es crítica cuando un sistema tiene millones de usuarios simultáneos? Pon ejemplos concretos con operaciones de búsqueda e inserción.

2. Implementa en C# una `PriorityQueue<Conductor, int>` para simular la asignación del conductor más cercano a un pasajero. ¿Por qué esta estructura es más eficiente que una lista ordenada?

3. ¿Cómo usarías un `Dictionary<string, List<Conductor>>` en C# para indexar conductores disponibles por zona? ¿Cuál es su complejidad de acceso?

4. Explica el algoritmo de Dijkstra para calcular la ruta más corta en un grafo. ¿En qué situaciones A\* sería preferible? Escribe el pseudocódigo o una implementación básica en C#.

5. ¿Qué estructura de datos usarías para almacenar el historial de viajes de un usuario permitiendo búsqueda rápida por fecha? Justifica tu elección.

6. Compara el rendimiento de `List<T>`, `LinkedList<T>` y `Queue<T>` en C# para operaciones de inserción y eliminación frecuentes en el contexto de una cola de viajes.

7. Si construyeran el módulo de asignación de viajes, ¿qué combinación de estructuras de datos usarían para minimizar el tiempo de respuesta?

8. Conclusiones individuales.

9. Bibliografía.

---

## Caso 4 — Microsoft Azure AD · Seguridad y Autenticación
### Preguntas de investigación

1. ¿Cuál es la diferencia entre autenticación y autorización? ¿Cómo las gestiona ASP.NET Core de forma independiente?

2. ¿Qué es un JWT (JSON Web Token)? Describe su estructura interna y demuestra en C# cómo validar uno usando `AddJwtBearer`.

3. ¿Qué flujo de OAuth 2.0 usarías para una aplicación web en ASP.NET Core? ¿Qué diferencia hay entre el flujo Authorization Code y el flujo Client Credentials?

4. ¿Qué es la autorización basada en roles (RBAC) y cómo se diferencia de la autorización basada en claims? ¿En qué escenario empresarial real conviene usar una u otra dentro de una aplicación ASP.NET Core?

5. ¿Por qué no se debe guardar una contraseña en texto plano? Explica el concepto de hash + salt e implementa un ejemplo en C# usando `BCrypt.Net` o `PBKDF2`.

6. ¿Qué son los ataques SQL Injection, XSS y CSRF? ¿Qué mecanismos ofrece ASP.NET Core para mitigar cada uno?

7. Si diseñaran el módulo de login de una app empresarial en C#, ¿qué capas de seguridad implementarían desde el registro del usuario hasta el acceso a un recurso protegido?

8. Conclusiones individuales.

9. Bibliografía.

---

## Estructura sugerida para la entrega

Cada grupo debe entregar su caso en una PPT con la siguiente estructura:  
• Portada con nombres del grupo.  
• Desarrollo de las preguntas.  
• Conclusiones individuales (una por integrante).  
• Bibliografía (fuentes confiables).  

