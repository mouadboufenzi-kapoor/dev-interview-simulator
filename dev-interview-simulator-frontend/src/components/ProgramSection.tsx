interface Challenge {
  id: string;
  title: string;
  description: string;
}

const CHALLENGES: readonly Challenge[] = [
  {
    id: 'qcm',
    title: 'QCM',
    description:
      'Des questions à choix multiples pour vérifier tes bases en Java, Spring Boot et bases de données.',
  },
  {
    id: 'code-review',
    title: 'Code review',
    description:
      'Analyse du code inspiré de situations réelles et repère ce qui cloche.',
  },
  {
    id: 'mises-en-situation',
    title: 'Mises en situation',
    description: 'Des scénarios proches de ceux des vrais entretiens techniques.',
  },
  {
    id: 'raisonnement-sequentiel',
    title: 'Raisonnement séquentiel',
    description: 'Remets les étapes dans le bon ordre pour montrer ta logique.',
  },
];

export const ProgramSection = () => (
  <section
    aria-labelledby="program-section-title"
    className="hidden text-left md:block md:pt-16 md:pb-14"
  >
    <h2
      id="program-section-title"
      className="font-mono text-[12px] uppercase tracking-[0.1em] text-[#52647a] dark:text-muted"
    >
      Au programme
    </h2>
    <ul className="mt-3.5 grid grid-cols-2 gap-5 lg:grid-cols-4">
      {CHALLENGES.map((challenge) => (
        <li
          key={challenge.id}
          className="rounded-[6px] border-2 border-[#0a2342] bg-white p-[22px] dark:border-border dark:bg-card"
        >
          <h3 className="text-[20px] font-bold text-[#0a2342] dark:text-text">
            {challenge.title}
          </h3>
          <p className="mt-2 text-[15px] leading-[1.5] text-[#52647a] dark:text-muted">
            {challenge.description}
          </p>
        </li>
      ))}
    </ul>
  </section>
);
