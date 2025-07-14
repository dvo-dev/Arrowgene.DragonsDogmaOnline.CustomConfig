using System.Linq;
using Arrowgene.Ddon.Server;
using Arrowgene.Ddon.Shared.Entity.PacketStructure;
using Arrowgene.Ddon.Shared.Model;
using Arrowgene.Logging;

namespace Arrowgene.Ddon.GameServer.Handler
{
    public class SkillGetAcquirableSkillListHandler : GameRequestPacketHandler<C2SSkillGetAcquirableSkillListReq, S2CSkillGetAcquirableSkillListRes>
    {
        private static readonly ServerLogger Logger = LogProvider.Logger<ServerLogger>(typeof(SkillGetCurrentSetSkillListHandler));

        public SkillGetAcquirableSkillListHandler(DdonGameServer server) : base(server)
        {
        }

        public override S2CSkillGetAcquirableSkillListRes Handle(GameClient client, C2SSkillGetAcquirableSkillListReq request)
        {
            // This list can't be filtered based on progress because it's cached between BBM and normal gameplay.
            //CharacterId = 0 in the request is for the player
            if (request.CharacterId == 0 || Server.GameSettings.GameServerSettings.PawnSkipJobTraining == false)
            {
                return new S2CSkillGetAcquirableSkillListRes()
                {
                    SkillParamList = client.Character.AcquirableSkills[request.Job]
                };
            }
            else 
            {
                var allDefaultSkills = SkillData.AllSkills.Where(x => x.Job == request.Job && !SkillData.IsUnlockableSkill(request.Job, x.SkillNo, 1));
                var pawnUnlocks = SkillData.AllSkills.Where(x => x.Job == request.Job
                    && SkillData.IsUnlockableSkill(request.Job, x.SkillNo, 1)
                    && client.Character.LearnedCustomSkills.Any(y => x.SkillNo == y.SkillId)
                    );
                return new S2CSkillGetAcquirableSkillListRes()
                {
                    SkillParamList = allDefaultSkills.Concat(pawnUnlocks).ToList()
                };
            }
        }
    }
}
