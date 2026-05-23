'use client';
import React, { useState } from 'react';

interface Proposal {
  id: number;
  title: string;
  description: string;
}

export default function ProposalVoting({ proposals }: { proposals: Proposal[] }) {
  const [votedIds, setVotedIds] = useState<number[]>([]);

  const handleVote = async (proposalId: number, choice: boolean) => {
    // Lógica para enviar el voto al servidor
    console.log(`Registrando voto para propuesta ${proposalId}: ${choice}`);
    
    // Simulamos éxito agregándolo al estado local
    setVotedIds([...votedIds, proposalId]);
    alert('Su voto ha sido registrado. ¡Gracias por participar!');
  };

  return (
    <div className="mt-8 space-y-6">
      <div className="border-b border-light-primary dark:border-dark-primary pb-2">
        <h3 className="text-xl font-bold text-slate-900 dark:text-violet-400">
          Propuestas de Mejoras y Proyectos
        </h3>
        <p className="text-xs text-slate-500">Tu voto decide el futuro del condominio</p>
      </div>

      <div className="grid grid-cols-1 gap-4">
        {proposals.map((proposal) => (
          <div 
            key={proposal.id} 
            className="p-5 rounded-xl border bg-light-surface dark:bg-dark-surface border-light-primary/20 dark:border-dark-primary/20 shadow-sm transition-all hover:shadow-md"
          >
            <h4 className="font-semibold text-lg text-light-primary dark:text-violet-300">
              {proposal.title}
            </h4>
            <p className="text-slate-600 dark:text-slate-400 mt-2 mb-4 text-sm leading-relaxed">
              {proposal.description}
            </p>
            
            <div className="flex gap-3">
              {votedIds.includes(proposal.id) ? (
                <span className="text-green-600 dark:text-green-400 font-medium text-sm flex items-center">
                  ✓ Su vivienda ya ejerció el voto para esta propuesta
                </span>
              ) : (
                <>
                  <button
                    onClick={() => handleVote(proposal.id, true)}
                    className="px-5 py-2 rounded-lg bg-light-primary dark:bg-dark-primary text-white text-sm font-bold hover:opacity-90 transition shadow-sm"
                  >
                    Votar a Favor
                  </button>
                  <button
                    onClick={() => handleVote(proposal.id, false)}
                    className="px-5 py-2 rounded-lg border border-red-500 text-red-500 dark:text-red-400 text-sm font-bold hover:bg-red-50 dark:hover:bg-red-900/10 transition"
                  >
                    En Contra
                  </button>
                </>
              )}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}