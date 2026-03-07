import { useState } from 'react';
import { User, Lock, Save, Loader2, Check } from 'lucide-react';
import { configService } from '../services/api';
import type { Usuario } from '../types';

interface ConfiguracoesProps {
  usuario: Usuario | null;
}

export default function Configuracoes({ usuario }: ConfiguracoesProps) {
  const [activeTab, setActiveTab] = useState<'perfil' | 'senha'>('perfil');
  const [saving, setSaving] = useState(false);
  const [saved, setSaved] = useState(false);
  const [nome, setNome] = useState(usuario?.nome || '');
  const [email, setEmail] = useState(usuario?.email || '');
  const [telefone, setTelefone] = useState(usuario?.telefone || '');
  const [senhaAtual, setSenhaAtual] = useState('');
  const [novaSenha, setNovaSenha] = useState('');
  const [confirmarSenha, setConfirmarSenha] = useState('');
  const [senhaError, setSenhaError] = useState('');

  const tipoLabel: Record<string, string> = { admin: 'Administrador', integradora: 'Integradora', tecnico: 'Técnico', produtor: 'Produtor' };

  const handleSalvarPerfil = async () => {
    setSaving(true);
    try {
      await configService.atualizarPerfil({ nome, email, telefone });
      const stored = localStorage.getItem('egranja_usuario');
      if (stored) { const u = JSON.parse(stored); u.nome = nome; u.email = email; u.telefone = telefone; localStorage.setItem('egranja_usuario', JSON.stringify(u)); }
      setSaved(true); setTimeout(() => setSaved(false), 3000);
    } catch { alert('Erro ao salvar perfil'); }
    finally { setSaving(false); }
  };

  const handleAlterarSenha = async () => {
    setSenhaError('');
    if (novaSenha !== confirmarSenha) { setSenhaError('As senhas não coincidem'); return; }
    if (novaSenha.length < 6) { setSenhaError('A senha deve ter pelo menos 6 caracteres'); return; }
    setSaving(true);
    try { await configService.alterarSenha(senhaAtual, novaSenha); setSenhaAtual(''); setNovaSenha(''); setConfirmarSenha(''); setSaved(true); setTimeout(() => setSaved(false), 3000); }
    catch { setSenhaError('Erro ao alterar senha. Verifique a senha atual.'); }
    finally { setSaving(false); }
  };

  return (
    <div className="space-y-6 max-w-2xl">
      <div><h1 className="text-2xl font-bold text-gray-900">Configurações</h1><p className="text-sm text-gray-500 mt-1">Gerencie seu perfil e senha</p></div>

      <div className="flex gap-1 border-b border-gray-200">
        <button onClick={() => setActiveTab('perfil')} className={`flex items-center gap-1.5 px-4 py-2.5 text-sm font-medium border-b-2 transition-colors ${activeTab === 'perfil' ? 'border-primary text-primary' : 'border-transparent text-gray-500 hover:text-gray-700'}`}><User className="w-4 h-4" />Perfil</button>
        <button onClick={() => setActiveTab('senha')} className={`flex items-center gap-1.5 px-4 py-2.5 text-sm font-medium border-b-2 transition-colors ${activeTab === 'senha' ? 'border-primary text-primary' : 'border-transparent text-gray-500 hover:text-gray-700'}`}><Lock className="w-4 h-4" />Alterar Senha</button>
      </div>

      {saved && (<div className="flex items-center gap-2 p-3 bg-green-50 border border-green-200 rounded-lg text-green-700 text-sm"><Check className="w-4 h-4" />Salvo com sucesso!</div>)}

      {activeTab === 'perfil' && (
        <div className="card space-y-4">
          <div className="flex items-center gap-4 pb-4 border-b border-gray-100">
            <div className="w-16 h-16 bg-primary rounded-full flex items-center justify-center"><span className="text-white text-2xl font-semibold">{usuario?.nome?.charAt(0).toUpperCase() || 'U'}</span></div>
            <div><h3 className="font-semibold text-gray-900">{usuario?.nome || 'Usuário'}</h3><p className="text-sm text-gray-500">{tipoLabel[usuario?.tipo || 'admin']}</p><p className="text-xs text-gray-400">Login: {usuario?.login}</p></div>
          </div>
          <div><label className="label-field">Nome completo</label><input type="text" className="input-field" value={nome} onChange={(e) => setNome(e.target.value)} /></div>
          <div><label className="label-field">E-mail</label><input type="email" className="input-field" value={email} onChange={(e) => setEmail(e.target.value)} /></div>
          <div><label className="label-field">Telefone</label><input type="text" className="input-field" value={telefone} onChange={(e) => setTelefone(e.target.value)} placeholder="(37) 99999-0000" /></div>
          <button onClick={handleSalvarPerfil} disabled={saving} className="btn-primary flex items-center gap-2">{saving ? <Loader2 className="w-4 h-4 animate-spin" /> : <Save className="w-4 h-4" />}Salvar Alterações</button>
        </div>
      )}

      {activeTab === 'senha' && (
        <div className="card space-y-4">
          {senhaError && (<div className="p-3 bg-red-50 border border-red-200 rounded-lg"><p className="text-sm text-red-700">{senhaError}</p></div>)}
          <div><label className="label-field">Senha atual</label><input type="password" className="input-field" value={senhaAtual} onChange={(e) => setSenhaAtual(e.target.value)} /></div>
          <div><label className="label-field">Nova senha</label><input type="password" className="input-field" value={novaSenha} onChange={(e) => setNovaSenha(e.target.value)} placeholder="Mínimo 6 caracteres" /></div>
          <div><label className="label-field">Confirmar nova senha</label><input type="password" className="input-field" value={confirmarSenha} onChange={(e) => setConfirmarSenha(e.target.value)} /></div>
          <button onClick={handleAlterarSenha} disabled={saving || !senhaAtual || !novaSenha || !confirmarSenha} className="btn-primary flex items-center gap-2">{saving ? <Loader2 className="w-4 h-4 animate-spin" /> : <Lock className="w-4 h-4" />}Alterar Senha</button>
        </div>
      )}
    </div>
  );
}
