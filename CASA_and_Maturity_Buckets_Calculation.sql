

alter proc	PRC_TIENGUI_HUYDONG
@NgayBD	date,
@NgayKT	date
as
begin
	with cte_tong_hop as (
        select 
            MA_TAIKHOAN_TIETKIEM as MA_TK,
            SOTIEN,
            LAISUAT,
            NGAY_GUI,
            NGAY_DENHAN,
            case 
                when KY_HAN <= 6 then N'Ngắn hạn'
                when KY_HAN > 12 then N'Dài hạn'
                else N'Trung hạn'
            end as [Nhóm kỳ hạn]
        from TIENGUI_TIETKIEM
        where NGAY_GUI BETWEEN @NgayBD AND @NgayKT

        union all
        select 
            MA_TAIKHOAN_THANHTOAN as MA_TK,
            avg(SODU_CUOI) as SOTIEN,
            0.5 as LAISUAT,
            @NgayBD as NGAY_GUI,
            @NgayKT as NGAY_DENHAN,
            N'CASA (Không kỳ hạn)' as [Nhóm kỳ hạn]
        from TIENGUI_THANHTOAN
        group by MA_TAIKHOAN_THANHTOAN
    )
    select 
        [Nhóm kỳ hạn],
        count(distinct MA_TK) as [Số tài khoản],
        sum(SOTIEN) as [Tổng số tiền gửi],
        sum(SOTIEN * (LAISUAT/100) * (datediff(day, NGAY_GUI, NGAY_DENHAN))/366) as [Tiền lãi]
    from cte_tong_hop
    group by [Nhóm kỳ hạn]
end;

exec PRC_TIENGUI_HUYDONG @NgayBD = '2024-01-01',
							@NgayKT	= '2024-12-31';
							USE mydatabase;
GO
EXEC dbo.PRC_TIENGUI_HUYDONGVON '2024-01-01', '2024-12-31';
select      *
from        TIENGUI_THANHTOAN
