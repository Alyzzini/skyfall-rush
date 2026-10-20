local Rules={}
function Rules.CanRank(run)
    if not run or run.usedSkip then return false,"USED SKIP" end
    if not run.eligible then return false,run.invalidReason or "UNRANKED" end
    if run.completedSections~=run.totalSections then return false,"INCOMPLETE ROUTE" end
    if not run.elapsed or run.elapsed<=0 then return false,"INVALID TIME" end
    return true,"RANKED"
end
function Rules.FormatTime(seconds)
    local ms=math.max(0,math.floor((seconds or 0)*1000+.5))
    return string.format("%02d:%02d.%03d",math.floor(ms/60000),math.floor(ms/1000)%60,ms%1000)
end
return Rules

